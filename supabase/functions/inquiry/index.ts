// ═══════════════════════════════════════════════════════════════════════════
// Supabase Edge Function — POST /functions/v1/inquiry
//
// Purpose: add an IP-scoped rate limit in front of the anonymous lead log.
//
// Defence in depth. The database already protects this path on its own:
//   * `inquiries` has an anon INSERT policy and NO anon SELECT policy,
//   * `guard_inquiry_rate()` caps one *device* at 10 submissions per 10 minutes,
//   * anon has no grant on `audit_log`, `profiles` or `inquiries` SELECT.
// This function adds the one thing the database cannot see: the caller's IP.
//
// It uses the service-role key, which is why it must never be bundled into the
// Flutter app — the key lives only in the function's own environment.
//
// NOTE: this file is part of the Phase 1 architecture but is not executed by
// the Phase 1 test suite (that suite runs the SQL layer). It is verified in
// Part 2 alongside the Edge Runtime tooling.
// ═══════════════════════════════════════════════════════════════════════════

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const CORS_HEADERS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const WINDOW_SECONDS = 60;
const MAX_PER_WINDOW = 6;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "content-type": "application/json" },
  });
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    return json({ error: "not_configured" }, 500);
  }

  let payload: { product_id?: string; channel?: string; device_id?: string };
  try {
    payload = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const channel = (payload.channel ?? "").trim();
  const allowed = new Set([
    "whatsapp",
    "telegram",
    "phone",
    "email",
    "instagram",
    "facebook",
    "tiktok",
    "youtube",
    "website",
    "location",
    "other",
  ]);
  if (!allowed.has(channel)) {
    return json({ error: "invalid_channel" }, 422);
  }

  const forwarded = req.headers.get("x-forwarded-for") ?? "";
  const ip = forwarded.split(",")[0].trim() || "unknown";

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  // Fixed-window counter keyed by IP. Cheap and good enough for a lead form;
  // a sliding-window or token-bucket scheme is a Part 2 refinement.
  const since = new Date(Date.now() - WINDOW_SECONDS * 1000).toISOString();
  const { count, error: countError } = await admin
    .from("inquiries")
    .select("id", { count: "exact", head: true })
    .eq("ip_hash", await hashIp(ip))
    .gte("created_at", since);

  if (countError) {
    return json({ error: "rate_limit_check_failed" }, 500);
  }
  if ((count ?? 0) >= MAX_PER_WINDOW) {
    return json({ error: "rate_limited" }, 429);
  }

  const { error: insertError } = await admin.from("inquiries").insert({
    product_id: payload.product_id ?? null,
    channel,
    device_id: (payload.device_id ?? "").slice(0, 128) || null,
    ip_hash: await hashIp(ip),
  });

  if (insertError) {
    // The SQL trigger raises P0001 when a device floods the endpoint.
    const status = insertError.code === "P0001" ? 429 : 500;
    return json({ error: insertError.message }, status);
  }

  return json({ ok: true }, 201);
});

/// Hashes the caller IP so the analytics table never stores a raw address.
async function hashIp(ip: string): Promise<string> {
  const data = new TextEncoder().encode(ip);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}
