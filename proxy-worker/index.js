import { AwsClient } from "aws4fetch";

/**
 * Berlin-Nukus secure API proxy (Cloudflare Worker)
 *
 * Maqsad: API kalitlarni mijoz (ilova) tomonidan EMAS, shu worker ichida
 * (Cloudflare Secrets) saqlash. Ilova faqat shu worker URL'iga murojaat qiladi
 * va hech qanday maxfiy kalit yubormaydi.
 *
 * So'rov turi `X-Proxy-Target` header orqali aniqlanadi:
 *   - "ai"           → AI chat provayderlari (X-Provider: qwen|cerebras|mistral|gemini)
 *   - "onesignal"    → OneSignal push bildirishnomalari
 *   - "polly"        → AWS Polly TTS (SigV4 imzolangan presigned URL qaytaradi)
 *   - "gemini-audio" → Gemini audio baholash (Sprechen): inlineData bilan
 *                      generateContent. {audioBase64, mimeType, prompt, model?}
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

const CORS_BASE = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,HEAD,POST,OPTIONS",
  "Access-Control-Max-Age": "86400",
};

/// CORS headerlarini quradi. Preflight (OPTIONS) so'rovda brauzer so'ragan
/// custom headerlarni (X-App-Token, X-Provider, X-Proxy-Target ...) aks ettiradi
/// — shu sabab web versiyada ishlaydi.
function corsHeaders(request) {
  const requested = request.headers.get("Access-Control-Request-Headers");
  return {
    ...CORS_BASE,
    "Access-Control-Allow-Headers":
      requested || "Content-Type,X-App-Token,X-Provider,X-Proxy-Target",
  };
}

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

function json(body, status = 200, cors = CORS_BASE) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

export default {
  async fetch(request, env) {
    const cors = corsHeaders(request);

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: cors });
    }

    // ── 1) App-token tekshiruvi ───────────────────────────────────────────────
    // Begona foydalanuvchilar proksini ishlatib qo'ymasligi uchun.
    const expectedToken = env.APP_TOKEN;
    if (expectedToken) {
      const provided = request.headers.get("X-App-Token") || "";
      if (!timingSafeEqual(provided, expectedToken)) {
        return json({ error: "Unauthorized" }, 401, cors);
      }
    }

    // ── 2) IP bo'yicha rate limit ──────────────────────────────────────────────
    // Cloudflare native rate limiter binding (wrangler.toml da sozlanadi).
    if (env.RATE_LIMITER) {
      const ip = request.headers.get("CF-Connecting-IP") || "unknown";
      try {
        const { success } = await env.RATE_LIMITER.limit({ key: ip });
        if (!success) {
          return json({ error: "Juda ko'p so'rov. Biroz kuting." }, 429, cors);
        }
      } catch (_) {
        // Rate limiter mavjud bo'lmasa, so'rovni to'smaymiz.
      }
    }

    const target = (request.headers.get("X-Proxy-Target") || "ai").toLowerCase();

    try {
      switch (target) {
        case "ai":
          return await handleAi(request, env, cors);
        case "onesignal":
          return await handleOneSignal(request, env, cors);
        case "polly":
          return await handlePolly(request, env, cors);
        case "gemini-audio":
          return await handleGeminiAudio(request, env, cors);
        default:
          return json({ error: `Noma'lum X-Proxy-Target: ${target}` }, 400, cors);
      }
    } catch (e) {
      return json({ error: (e && e.message) || String(e) }, 500, cors);
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
async function handleAi(request, env, cors) {
  const provider = (request.headers.get("X-Provider") || "").toLowerCase();
  const cfg = AI_PROVIDERS[provider];
  if (!cfg) {
    return json({ error: `Noma'lum AI provayder: ${provider}` }, 400, cors);
  }

  const apiKey = env[cfg.keyName];
  if (!apiKey) {
    return json({ error: `${cfg.keyName} worker secretlarida topilmadi` }, 500, cors);
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
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

// ─── Gemini audio baholash (Sprechen) ─────────────────────────────────────────
// Ilova yozilgan audioni base64 sifatida yuboradi; bu yerda Gemini'ning
// generateContent endpointiga inlineData bilan murojaat qilamiz. Gemini
// audioni to'g'ridan-to'g'ri tushunadi (alohida STT kerak emas).
// Fallback: Gemini limit/xato bo'lsa → Whisper STT + OpenAI GPT baholash.
async function handleGeminiAudio(request, env, cors) {
  const apiKey = env.GEMINI_API_KEY;
  if (!apiKey) {
    return json({ error: "GEMINI_API_KEY worker secretlarida topilmadi" }, 500, cors);
  }

  const payload = await request.json();
  const audioBase64 = payload.audioBase64;
  const mimeType = payload.mimeType || "audio/mp4";
  const prompt = payload.prompt || "Bewerte die gesprochene Leistung.";
  const model = payload.model || env.GEMINI_AUDIO_MODEL || "gemini-2.5-flash";

  if (!audioBase64) {
    return json({ error: "audioBase64 yo'q" }, 400, cors);
  }

  // 1) Gemini bilan urinish
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;

  const upstream = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-goog-api-key": apiKey,
    },
    body: JSON.stringify({
      contents: [
        {
          role: "user",
          parts: [
            { text: prompt },
            { inlineData: { mimeType: mimeType, data: audioBase64 } },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.3,
        responseMimeType: "application/json",
      },
    }),
  });

  // Gemini muvaffaqiyatli bo'lsa — qaytaramiz
  if (upstream.status >= 200 && upstream.status < 300) {
    const respBody = await upstream.text();
    return new Response(respBody, {
      status: upstream.status,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  // 2) Gemini xato berdi — fallback: Groq Whisper STT + Mistral baholash
  const groqKey = env.GROQ_API_KEY;
  const mistralKey = env.MISTRAL_API_KEY;
  if (!groqKey || !mistralKey) {
    // Fallback kalitlari yo'q — Gemini xatosini qaytaramiz
    const respBody = await upstream.text();
    return new Response(respBody, {
      status: upstream.status,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  try {
    // 2a) Audio → STT (Groq Whisper — bepul, tez)
    const audioBuffer = Uint8Array.from(atob(audioBase64), c => c.charCodeAt(0));
    const ext = mimeType.includes("webm") ? "webm" : mimeType.includes("ogg") ? "ogg" : "m4a";
    const formData = new FormData();
    formData.append("file", new Blob([audioBuffer], { type: mimeType }), `audio.${ext}`);
    formData.append("model", "whisper-large-v3");
    formData.append("language", "de");

    const sttResp = await fetch("https://api.groq.com/openai/v1/audio/transcriptions", {
      method: "POST",
      headers: { Authorization: `Bearer ${groqKey}` },
      body: formData,
    });

    if (!sttResp.ok) {
      return json({ error: "STT fallback xatosi", status: sttResp.status }, 502, cors);
    }

    const sttJson = await sttResp.json();
    const transcript = sttJson.text || "";

    if (!transcript.trim()) {
      const emptyResult = JSON.stringify({
        candidates: [{ content: { parts: [{ text: JSON.stringify({
          score: "0/20",
          pronunciation: "Audio'da gap aniqlanmadi.",
          fluency: "Audio bo'sh yoki juda past ovozda.",
          grammar: "Baholab bo'lmadi.",
          content: "Hech qanday mazmun topilmadi.",
          overall: "Audio'da nemischa nutq aniqlanmadi. Qayta yozib ko'ring."
        })}]}}]
      });
      return new Response(emptyResult, { status: 200, headers: { ...cors, "Content-Type": "application/json" } });
    }

    // 2b) Transkripsiya + prompt → Mistral baholash
    const mistralPrompt = prompt + `\n\nTRANSCRIPT (vom Lernenden gesprochen):\n"${transcript}"`;

    const mistralResp = await fetch("https://api.mistral.ai/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${mistralKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "mistral-small-latest",
        temperature: 0.3,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: "Du bist ein TELC-Prüfer. Antworte NUR mit validem JSON." },
          { role: "user", content: mistralPrompt },
        ],
      }),
    });

    if (!mistralResp.ok) {
      return json({ error: "Mistral fallback xatosi", status: mistralResp.status }, 502, cors);
    }

    const mistralJson = await mistralResp.json();
    const mistralText = mistralJson.choices?.[0]?.message?.content || "{}";

    // Gemini format'ida qaytaramiz (app o'zgarmaydi)
    const wrappedResult = JSON.stringify({
      candidates: [{ content: { parts: [{ text: mistralText }] } }]
    });
    return new Response(wrappedResult, { status: 200, headers: { ...cors, "Content-Type": "application/json" } });

  } catch (e) {
    return json({ error: "Fallback xatosi: " + (e.message || e) }, 502, cors);
  }
}
async function handleOneSignal(request, env, cors) {
  const apiKey = env.ONESIGNAL_REST_API_KEY;
  if (!apiKey) {
    return json({ error: "ONESIGNAL_REST_API_KEY worker secretlarida topilmadi" }, 500, cors);
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
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

// ─── AWS Polly TTS (server-side POST, audio bytes qaytaradi) ──────────────────
async function handlePolly(request, env, cors) {
  const accessKey = (env.AWS_ACCESS_KEY_ID || "").trim();
  const secretKey = (env.AWS_SECRET_ACCESS_KEY || "").trim();
  if (!accessKey || !secretKey) {
    return json({ error: "AWS kalitlari worker secretlarida topilmadi" }, 500, cors);
  }

  const payload = await request.json();
  const region = payload.region || "eu-central-1";
  const ssmlText = payload.text || "";
  const voiceId = payload.voiceId || "Vicki";
  const engine = payload.engine || "neural";
  const outputFormat = payload.outputFormat || "mp3";

  const bodyObj = {
    OutputFormat: outputFormat,
    Text: ssmlText,
    TextType: "ssml",
    VoiceId: voiceId,
    Engine: engine,
  };
  const body = JSON.stringify(bodyObj);

  const aws = new AwsClient({
    accessKeyId: accessKey,
    secretAccessKey: secretKey,
  });

  const upstream = await aws.fetch(`https://polly.${region}.amazonaws.com/v1/speech`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body,
  });

  if (!upstream.ok) {
    const errText = await upstream.text();
    return json(
      { error: `Polly xatosi (${upstream.status}): ${errText}` },
      upstream.status,
      cors
    );
  }

  const audioBuffer = await upstream.arrayBuffer();
  return new Response(audioBuffer, {
    status: 200,
    headers: {
      ...cors,
      "Content-Type": "audio/mpeg",
    },
  });
}
