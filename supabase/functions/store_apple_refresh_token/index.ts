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
    return errorResponse(401, "Invalid or expired session");
  }

  let body: { authorization_code?: string };
  try {
    body = await req.json();
  } catch {
    return errorResponse(400, "Invalid JSON body");
  }

  const authorizationCode = body.authorization_code?.trim();
  if (!authorizationCode) {
    return errorResponse(400, "authorization_code is required");
  }

  if (!APPLE_CLIENT_ID || !APPLE_TEAM_ID || !APPLE_KEY_ID || !APPLE_PRIVATE_KEY) {
    return errorResponse(500, "Apple Sign in revocation secrets are not configured");
  }

  const clientSecret = await generateAppleClientSecret();

  const tokenResp = await fetch("https://appleid.apple.com/auth/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "authorization_code",
      code: authorizationCode,
      client_id: APPLE_CLIENT_ID,
      client_secret: clientSecret,
    }),
  });

  const tokenJson = await tokenResp.json().catch(() => ({}));
  if (!tokenResp.ok) {
    return errorResponse(500, `Apple token exchange failed: ${JSON.stringify(tokenJson)}`);
  }

  const refreshToken = typeof tokenJson.refresh_token === "string"
    ? tokenJson.refresh_token
    : null;

  // Apple returns refresh_token only on first successful authorization for a user/app.
  // If it's not present, keep existing token (if any) and return success.
  if (!refreshToken) {
    return jsonResponse(200, { ok: true, stored: false, reason: "no_refresh_token_returned" });
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
  const { error: upsertErr } = await admin
    .from("apple_auth_tokens")
    .upsert({ user_id: user.id, refresh_token: refreshToken }, { onConflict: "user_id" });

  if (upsertErr) {
    return errorResponse(500, `Failed to save refresh token: ${upsertErr.message}`);
  }

  return jsonResponse(200, { ok: true, stored: true });
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
