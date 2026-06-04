/**
 * Berlin-Nukus secure API proxy (Cloudflare Worker)
 *
 * Maqsad: API kalitlarni mijoz (ilova) tomonidan EMAS, shu worker ichida
 * (Cloudflare Secrets) saqlash. Ilova faqat shu worker URL'iga murojaat qiladi
 * va hech qanday maxfiy kalit yubormaydi.
 *
 * So'rov turi `X-Proxy-Target` header orqali aniqlanadi:
 *   - "ai"        → AI chat provayderlari (X-Provider: qwen|cerebras|mistral|gemini)
 *   - "onesignal" → OneSignal push bildirishnomalari
 *   - "polly"     → AWS Polly TTS (SigV4 imzolangan presigned URL qaytaradi)
 *
 * Worker secretlari (wrangler secret put ... yoki dashboard orqali):
 *   QWEN_API_KEY, CEREBRAS_API_KEY, MISTRAL_API_KEY, GEMINI_API_KEY,
 *   ONESIGNAL_REST_API_KEY, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY,
 *   APP_TOKEN  (ilova yuboradigan maxfiy token — faqat shu token bilan ruxsat)
 *
 * Himoya:
 *   1) APP_TOKEN — ilova har so'rovda "X-App-Token" header yuboradi. Mos
 *      kelmasa 401 qaytadi (begona open-proxy bo'lib qolmaslik uchun).
 *   2) Rate limit — har IP uchun daqiqada cheklangan so'rov (wrangler.toml
 *      dagi RATE_LIMITER binding orqali).
 */

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,HEAD,POST,OPTIONS",
  "Access-Control-Max-Age": "86400",
  "Access-Control-Allow-Headers": "*",
};

// AI provayder konfiguratsiyasi: base URL + qaysi secret ishlatilishi.
const AI_PROVIDERS = {
  qwen: {
    url: "https://dashscope-intl.aliyuncs.com/compatible-mode/v1/chat/completions",
    keyName: "QWEN_API_KEY",
  },
  cerebras: {
    url: "https://api.cerebras.ai/v1/chat/completions",
    keyName: "CEREBRAS_API_KEY",
  },
  mistral: {
    url: "https://api.mistral.ai/v1/chat/completions",
    keyName: "MISTRAL_API_KEY",
  },
  gemini: {
    url: "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
    keyName: "GEMINI_API_KEY",
  },
};

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: CORS_HEADERS });
    }

    // ── 1) App-token tekshiruvi ───────────────────────────────────────────────
    // Begona foydalanuvchilar proksini ishlatib qo'ymasligi uchun.
    const expectedToken = env.APP_TOKEN;
    if (expectedToken) {
      const provided = request.headers.get("X-App-Token") || "";
      if (!timingSafeEqual(provided, expectedToken)) {
        return json({ error: "Unauthorized" }, 401);
      }
    }

    // ── 2) IP bo'yicha rate limit ──────────────────────────────────────────────
    // Cloudflare native rate limiter binding (wrangler.toml da sozlanadi).
    if (env.RATE_LIMITER) {
      const ip = request.headers.get("CF-Connecting-IP") || "unknown";
      try {
        const { success } = await env.RATE_LIMITER.limit({ key: ip });
        if (!success) {
          return json({ error: "Juda ko'p so'rov. Biroz kuting." }, 429);
        }
      } catch (_) {
        // Rate limiter mavjud bo'lmasa, so'rovni to'smaymiz.
      }
    }

    const target = (request.headers.get("X-Proxy-Target") || "ai").toLowerCase();

    try {
      switch (target) {
        case "ai":
          return await handleAi(request, env);
        case "onesignal":
          return await handleOneSignal(request, env);
        case "polly":
          return await handlePolly(request, env);
        default:
          return json({ error: `Noma'lum X-Proxy-Target: ${target}` }, 400);
      }
    } catch (e) {
      return json({ error: (e && e.message) || String(e) }, 500);
    }
  },
};

/// Vaqt bo'yicha barqaror string solishtirish (token uzunligini oshkor qilmaydi).
function timingSafeEqual(a, b) {
  if (typeof a !== "string" || typeof b !== "string") return false;
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return result === 0;
}

// ─── AI chat provayderlari ──────────────────────────────────────────────────
async function handleAi(request, env) {
  const provider = (request.headers.get("X-Provider") || "").toLowerCase();
  const cfg = AI_PROVIDERS[provider];
  if (!cfg) {
    return json({ error: `Noma'lum AI provayder: ${provider}` }, 400);
  }

  const apiKey = env[cfg.keyName];
  if (!apiKey) {
    return json({ error: `${cfg.keyName} worker secretlarida topilmadi` }, 500);
  }

  const bodyText = await request.text();

  const upstream = await fetch(cfg.url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: bodyText,
  });

  const respBody = await upstream.text();
  return new Response(respBody, {
    status: upstream.status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

// ─── OneSignal push ───────────────────────────────────────────────────────────
async function handleOneSignal(request, env) {
  const apiKey = env.ONESIGNAL_REST_API_KEY;
  if (!apiKey) {
    return json({ error: "ONESIGNAL_REST_API_KEY worker secretlarida topilmadi" }, 500);
  }

  const bodyText = await request.text();

  const upstream = await fetch("https://api.onesignal.com/notifications?c=push", {
    method: "POST",
    headers: {
      Authorization: `Basic ${apiKey}`,
      "Content-Type": "application/json; charset=utf-8",
      accept: "application/json",
    },
    body: bodyText,
  });

  const respBody = await upstream.text();
  return new Response(respBody, {
    status: upstream.status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

// ─── AWS Polly TTS (SigV4 presigned URL) ───────────────────────────────────────
async function handlePolly(request, env) {
  const accessKey = env.AWS_ACCESS_KEY_ID;
  const secretKey = env.AWS_SECRET_ACCESS_KEY;
  if (!accessKey || !secretKey) {
    return json({ error: "AWS kalitlari worker secretlarida topilmadi" }, 500);
  }

  const payload = await request.json();
  const region = payload.region || "eu-central-1";
  const ssmlText = payload.text || "";
  const voiceId = payload.voiceId || "Vicki";
  const engine = payload.engine || "neural";
  const outputFormat = payload.outputFormat || "mp3";

  const host = `polly.${region}.amazonaws.com`;
  const path = "/v1/speech";
  const service = "polly";

  const now = new Date();
  const amzDate = now.toISOString().replace(/[:-]|\.\d{3}/g, ""); // YYYYMMDDTHHMMSSZ
  const dateStamp = amzDate.slice(0, 8);

  const credentialScope = `${dateStamp}/${region}/${service}/aws4_request`;

  // Presign uchun query parametrlari (alfavit tartibida)
  const query = {
    Engine: engine,
    OutputFormat: outputFormat,
    Text: ssmlText,
    TextType: "ssml",
    VoiceId: voiceId,
    "X-Amz-Algorithm": "AWS4-HMAC-SHA256",
    "X-Amz-Credential": `${accessKey}/${credentialScope}`,
    "X-Amz-Date": amzDate,
    "X-Amz-Expires": "900",
    "X-Amz-SignedHeaders": "host",
  };

  const canonicalQuery = Object.keys(query)
    .sort()
    .map((k) => `${encodeRfc3986(k)}=${encodeRfc3986(query[k])}`)
    .join("&");

  const canonicalHeaders = `host:${host}\n`;
  const signedHeaders = "host";
  const payloadHash = await sha256Hex("");

  const canonicalRequest = [
    "GET",
    path,
    canonicalQuery,
    canonicalHeaders,
    signedHeaders,
    payloadHash,
  ].join("\n");

  const stringToSign = [
    "AWS4-HMAC-SHA256",
    amzDate,
    credentialScope,
    await sha256Hex(canonicalRequest),
  ].join("\n");

  const signingKey = await getSignatureKey(secretKey, dateStamp, region, service);
  const signature = bufToHex(await hmac(signingKey, stringToSign));

  const presignedUrl = `https://${host}${path}?${canonicalQuery}&X-Amz-Signature=${signature}`;

  return json({ url: presignedUrl });
}

// ─── Crypto yordamchilari (Web Crypto API) ─────────────────────────────────────
function encodeRfc3986(str) {
  return encodeURIComponent(str).replace(
    /[!'()*]/g,
    (c) => "%" + c.charCodeAt(0).toString(16).toUpperCase()
  );
}

async function sha256Hex(message) {
  const data = new TextEncoder().encode(message);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return bufToHex(hash);
}

function bufToHex(buffer) {
  return [...new Uint8Array(buffer)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

async function hmac(key, message) {
  const cryptoKey = await crypto.subtle.importKey(
    "raw",
    key instanceof Uint8Array ? key : new TextEncoder().encode(key),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  return crypto.subtle.sign("HMAC", cryptoKey, new TextEncoder().encode(message));
}

async function getSignatureKey(secretKey, dateStamp, region, service) {
  const kDate = await hmac(`AWS4${secretKey}`, dateStamp);
  const kRegion = await hmac(new Uint8Array(kDate), region);
  const kService = await hmac(new Uint8Array(kRegion), service);
  const kSigning = await hmac(new Uint8Array(kService), "aws4_request");
  return new Uint8Array(kSigning);
}
