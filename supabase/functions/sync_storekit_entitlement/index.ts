import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose@5.9.6";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const APPSTORE_ISSUER_ID = Deno.env.get("APPSTORE_ISSUER_ID") ?? "";
const APPSTORE_KEY_ID = Deno.env.get("APPSTORE_KEY_ID") ?? "";
const APPSTORE_PRIVATE_KEY = (Deno.env.get("APPSTORE_PRIVATE_KEY") ?? "").replace(/\\n/g, "\n");
const APPSTORE_BUNDLE_ID = Deno.env.get("APPSTORE_BUNDLE_ID") ?? "";

const PREMIUM_PRODUCT_IDS = (Deno.env.get("PREMIUM_PRODUCT_IDS") ?? "premium_lifetime")
  .split(",")
  .map((value) => value.trim())
  .filter((value) => value.length > 0);

const REQUIRE_APP_ACCOUNT_TOKEN = (Deno.env.get("REQUIRE_APP_ACCOUNT_TOKEN") ?? "1") === "1";
const APPLE_PRODUCTION_URL = "https://api.storekit.itunes.apple.com";
const APPLE_SANDBOX_URL = "https://api.storekit-sandbox.itunes.apple.com";

interface SyncRequest {
  product_id?: string;
  transaction_id?: string;
}

interface AppleTransactionLookupResponse {
  signedTransactionInfo?: string;
}

interface AppStoreTransactionPayload {
  transactionId?: string;
  originalTransactionId?: string;
  productId?: string;
  bundleId?: string;
  appAccountToken?: string;
  revocationDate?: number;
}

interface EntitlementMetadata {
  last_transaction_id?: string | null;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  // verify_jwt is disabled for this function because Supabase gateway JWT checks
  // are incompatible with newer ES256 signing keys; validate the caller here instead.
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

  let body: SyncRequest = {};
  try {
    body = await req.json();
  } catch {
    // Empty body is allowed for reconciliation mode.
  }

  const productId = body.product_id?.trim();
  if (!productId || !PREMIUM_PRODUCT_IDS.includes(productId)) {
    return errorResponse(400, "Invalid or unsupported product_id");
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
  let verificationTransactionID = body.transaction_id?.trim() ?? null;

  if (!verificationTransactionID) {
    const { data: existing, error: existingErr } = await admin
      .from("user_entitlements")
      .select("metadata")
      .eq("user_id", user.id)
      .maybeSingle();

    if (existingErr) {
      return errorResponse(500, `Failed to read existing entitlement metadata: ${existingErr.message}`);
    }

    const existingMetadata = (existing?.metadata ?? {}) as EntitlementMetadata;
    verificationTransactionID = existingMetadata.last_transaction_id?.trim() ?? null;
  }

  if (!verificationTransactionID) {
    // No transaction id to verify; ensure backend reflects no premium.
    const { error: upsertErr } = await admin
      .from("user_entitlements")
      .upsert({
        user_id: user.id,
        is_pro: false,
        has_lifetime: false,
        source: "app_store_server_api",
        metadata: {
          last_transaction_id: null,
          original_transaction_id: null,
          last_checked_at: new Date().toISOString(),
        },
      }, { onConflict: "user_id" });

    if (upsertErr) {
      return errorResponse(500, `Failed to upsert entitlement: ${upsertErr.message}`);
    }

    return jsonResponse(200, {
      ok: true,
      has_premium: false,
      last_transaction_id: null,
      verification_environment: null,
    });
  }

  const verification = await verifyTransactionWithApple(verificationTransactionID);
  if (!verification.ok || !verification.payload) {
    return errorResponse(400, verification.error ?? "Could not verify transaction with Apple");
  }

  const payload = verification.payload;
  if (payload.productId !== productId) {
    return errorResponse(400, "Transaction product mismatch");
  }
  if (payload.bundleId !== APPSTORE_BUNDLE_ID) {
    return errorResponse(400, "Transaction bundle mismatch");
  }

  const lastTransactionId = payload.transactionId ?? verificationTransactionID;
  const ownershipTransactionId =
    payload.originalTransactionId ?? lastTransactionId;
  const tokenFromApple = payload.appAccountToken?.toLowerCase();
  const userIdLower = user.id.toLowerCase();

  const { data: existingOwner, error: ownerErr } = await admin
    .from("user_entitlements")
    .select("user_id")
    .eq("metadata->>last_transaction_id", lastTransactionId)
    .maybeSingle();

  if (ownerErr) {
    return errorResponse(500, `Failed to check entitlement owner: ${ownerErr.message}`);
  }

  if (REQUIRE_APP_ACCOUNT_TOKEN) {
    // New purchases stay bound to the original app account. If the old app account
    // was deleted, its entitlement row is gone and the current user may reclaim the
    // verified Apple entitlement on login or Restore Purchases.
    const appAccountMatchesCurrentUser = tokenFromApple === userIdLower;
    const transactionIsUnclaimed = !existingOwner?.user_id;
    const transactionOwnedByCurrentUser = existingOwner?.user_id === user.id;
    if (!appAccountMatchesCurrentUser && !transactionIsUnclaimed && !transactionOwnedByCurrentUser) {
      return errorResponse(403, "Transaction does not belong to this user");
    }
  }

  const isPremiumActive = payload.revocationDate == null;

  const { error: upsertErr } = await admin
    .from("user_entitlements")
    .upsert({
      user_id: user.id,
      is_pro: isPremiumActive,
      has_lifetime: isPremiumActive,
      source: "app_store_server_api",
      metadata: {
        last_transaction_id: lastTransactionId,
        original_transaction_id: ownershipTransactionId,
        verification_environment: verification.environment,
        last_checked_at: new Date().toISOString(),
      },
    }, { onConflict: "user_id" });

  if (upsertErr) {
    return errorResponse(500, `Failed to update entitlement: ${upsertErr.message}`);
  }

  return jsonResponse(200, {
    ok: true,
    has_premium: isPremiumActive,
    last_transaction_id: lastTransactionId,
    verification_environment: verification.environment,
  });
});

async function verifyTransactionWithApple(transactionId: string): Promise<{
  ok: boolean;
  payload?: AppStoreTransactionPayload;
  environment?: "production" | "sandbox";
  error?: string;
}> {
  if (!APPSTORE_ISSUER_ID || !APPSTORE_KEY_ID || !APPSTORE_PRIVATE_KEY || !APPSTORE_BUNDLE_ID) {
    return { ok: false, error: "App Store verification secrets are not configured" };
  }

  const jwt = await generateAppStoreJWT();
  const environments: Array<{ baseUrl: string; label: "production" | "sandbox" }> = [
    { baseUrl: APPLE_PRODUCTION_URL, label: "production" },
    { baseUrl: APPLE_SANDBOX_URL, label: "sandbox" },
  ];

  let lastError = "";

  for (const environment of environments) {
    const response = await fetch(`${environment.baseUrl}/inApps/v1/transactions/${transactionId}`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${jwt}`,
        "Content-Type": "application/json",
      },
    });

    if (!response.ok) {
      lastError = await response.text();
      continue;
    }

    const body = (await response.json()) as AppleTransactionLookupResponse;
    if (!body.signedTransactionInfo) {
      return { ok: false, error: "Apple response missing signedTransactionInfo" };
    }

    const payload = decodeJWSPayload<AppStoreTransactionPayload>(body.signedTransactionInfo);
    return {
      ok: true,
      payload,
      environment: environment.label,
    };
  }

  return { ok: false, error: `Apple verification failed for transaction ${transactionId}: ${lastError}` };
}

async function generateAppStoreJWT(): Promise<string> {
  const algorithm = "ES256";
  const privateKey = await importPKCS8(APPSTORE_PRIVATE_KEY, algorithm);
  const now = Math.floor(Date.now() / 1000);

  return await new SignJWT({ bid: APPSTORE_BUNDLE_ID })
    .setProtectedHeader({ alg: algorithm, kid: APPSTORE_KEY_ID, typ: "JWT" })
    .setIssuer(APPSTORE_ISSUER_ID)
    .setAudience("appstoreconnect-v1")
    .setIssuedAt(now)
    .setExpirationTime(now + 60 * 10)
    .sign(privateKey);
}

function decodeJWSPayload<T>(signedValue: string): T {
  const parts = signedValue.split(".");
  if (parts.length < 2) {
    throw new Error("Invalid JWS payload");
  }

  const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
  const padding = base64.length % 4;
  const padded = base64 + (padding > 0 ? "=".repeat(4 - padding) : "");
  const decoded = atob(padded);
  return JSON.parse(decoded) as T;
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
