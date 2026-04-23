import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose@5.9.6";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const APPLE_CLIENT_ID = Deno.env.get("APPLE_CLIENT_ID") ?? "";
const APPLE_TEAM_ID = Deno.env.get("APPLE_TEAM_ID") ?? "";
const APPLE_KEY_ID = Deno.env.get("APPLE_KEY_ID") ?? "";
const APPLE_PRIVATE_KEY = (Deno.env.get("APPLE_PRIVATE_KEY") ?? "").replace(/\\n/g, "\n");

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {
    return errorResponse(401, "Missing or invalid Authorization header");
  }

  const userClient = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: { user }, error: authErr } = await userClient.auth.getUser();
  if (authErr || !user) {
    console.error("[delete_account] Auth failed:", authErr?.message ?? "no user");
    return errorResponse(401, "Invalid or expired session");
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  // Revoke SIWA refresh token if available to comply with Apple account deletion guidance.
  const { data: appleTokenRow, error: tokenFetchErr } = await admin
    .from("apple_auth_tokens")
    .select("refresh_token")
    .eq("user_id", user.id)
    .maybeSingle();

  if (tokenFetchErr) {
    return errorResponse(500, `Failed to load Apple token: ${tokenFetchErr.message}`);
  }

  if (appleTokenRow?.refresh_token) {
    if (!APPLE_CLIENT_ID || !APPLE_TEAM_ID || !APPLE_KEY_ID || !APPLE_PRIVATE_KEY) {
      return errorResponse(500, "Apple Sign in revocation secrets are not configured");
    }

    const clientSecret = await generateAppleClientSecret();
    const revokeResp = await fetch("https://appleid.apple.com/auth/revoke", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        client_id: APPLE_CLIENT_ID,
        client_secret: clientSecret,
        token: appleTokenRow.refresh_token,
        token_type_hint: "refresh_token",
      }),
    });

    // Apple may return 200 for both already-revoked and successful revocation.
    if (!revokeResp.ok) {
      const revokeBody = await revokeResp.text();
      return errorResponse(500, `Failed to revoke Apple token: ${revokeBody}`);
    }
  }

  const { error: deleteErr } = await admin.auth.admin.deleteUser(user.id);
  if (deleteErr) {
    console.error("[delete_account] Delete failed:", deleteErr.message);
    return errorResponse(500, `Failed to delete account: ${deleteErr.message}`);
  }

  return jsonResponse(200, {
    ok: true,
    user_id: user.id,
  });
});

async function generateAppleClientSecret(): Promise<string> {
  const alg = "ES256";
  const privateKey = await importPKCS8(APPLE_PRIVATE_KEY, alg);
  const now = Math.floor(Date.now() / 1000);

  return await new SignJWT({})
    .setProtectedHeader({ alg, kid: APPLE_KEY_ID })
    .setIssuer(APPLE_TEAM_ID)
    .setAudience("https://appleid.apple.com")
    .setSubject(APPLE_CLIENT_ID)
    .setIssuedAt(now)
    .setExpirationTime(now + 60 * 60 * 24 * 180)
    .sign(privateKey);
}

function jsonResponse(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}

function errorResponse(status: number, message: string): Response {
  return jsonResponse(status, { error: message });
}
