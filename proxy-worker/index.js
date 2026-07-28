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
  async fetch(request, env, ctx) {
    const cors = corsHeaders(request);

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: cors });
    }

    // ── 0) WebSocket (Gemini Live real-time proksi) ───────────────────────────
    // Brauzer WS custom header (X-App-Token) yubora olmaydi — shuning uchun bu
    // tekshiruvdan oldin ushlaymiz; app token query param orqali tekshiriladi.
    if ((request.headers.get("Upgrade") || "").toLowerCase() === "websocket") {
      // Har ulanish uchun alohida Durable Object instansi — ulanish davomida
      // tirik turadi (oddiy Worker'dagi "internal error"/evict muammosi yo'q).
      const id = env.LIVE_RELAY.newUniqueId();
      const stub = env.LIVE_RELAY.get(id);
      return stub.fetch(request);
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
        // Pipeline qo'llab-quvvatlanmaydi — Gemini Live native audio ishlatiladi
        // case "stt":
        //   return await handleStt(request, env, cors);
        case "gemini-live-token":
          return await handleGeminiLiveToken(request, env, cors);
        // case "elevenlabs-tts":
        //   return await handleElevenLabsTts(request, env, cors);
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

  let apiKey = env[cfg.keyName];
  if (!apiKey) {
    return json({ error: `${cfg.keyName} worker secretlarida topilmadi` }, 500, cors);
  }

  const bodyText = await request.text();

  let upstream = await fetch(cfg.url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: bodyText,
  });

  if (provider === "gemini" && upstream.status === 429 && env.FALLBACK_GEMINI_API_KEY) {
    console.log("handleAi: Gemini 429, zaxira kalitga o'tilmoqda...");
    upstream = await fetch(cfg.url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${env.FALLBACK_GEMINI_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: bodyText,
    });
  }

  const respBody = await upstream.text();
  return new Response(respBody, {
    status: upstream.status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

// ─── Gemini Live — qisqa muddatli (ephemeral) token ──────────────────────────
// Real-time ovozli AI (BidiGenerateContent) uchun. API kalit ILOVAGA
// yuborilmaydi — bu yerda qisqa muddatli token yaratiladi va ilova o'sha token
// bilan WebSocket'ga ulanadi. Javob: {token} (auth_tokens/... nomi).
async function handleGeminiLiveToken(request, env, cors) {
  const apiKey = env.GEMINI_API_KEY;
  if (!apiKey) {
    return json({ error: "GEMINI_API_KEY worker secretlarida topilmadi" }, 500, cors);
  }

  // Token qisqa muddat amal qiladi (masalan 30 daqiqa), bitta yangi sessiya
  // ochish uchun (newSessionExpireTime ~5 daqiqa).
  const now = Date.now();
  const expireTime = new Date(now + 30 * 60 * 1000).toISOString();
  const newSessionExpireTime = new Date(now + 5 * 60 * 1000).toISOString();

  try {
    let resp = await fetch(
      `https://generativelanguage.googleapis.com/v1alpha/auth_tokens?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          uses: 1,
          expireTime,
          newSessionExpireTime,
        }),
      }
    );

    if (resp.status === 429 && env.FALLBACK_GEMINI_API_KEY) {
      console.log("handleGeminiLiveToken: 429, zaxira kalitga o'tilmoqda...");
      resp = await fetch(
        `https://generativelanguage.googleapis.com/v1alpha/auth_tokens?key=${env.FALLBACK_GEMINI_API_KEY}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            uses: 1,
            expireTime,
            newSessionExpireTime,
          }),
        }
      );
    }

    const data = await resp.json();
    if (!resp.ok) {
      return json(
        { error: `Live token xato (${resp.status}): ${JSON.stringify(data).slice(0, 200)}` },
        502,
        cors
      );
    }
    // data.name => "auth_tokens/xxxxx" — WebSocket'da access_token sifatida.
    return json({ token: data.name || "" }, 200, cors);
  } catch (e) {
    return json({ error: (e && e.message) || String(e) }, 500, cors);
  }
}

// ─── Gemini Live WebSocket proksi (Durable Object) ───────────────────────────
// Har ulanish uchun alohida DO instansi ochiladi. Oddiy Worker'dan farqli
// o'laroq, DO ulanish davomida xotirada TIRIK turadi — shuning uchun uzoq
// audio oqimida "internal error"/evict (1006) muammosi yo'q.
export class LiveRelay {
  constructor(state, env) {
    this.state = state;
    this.env = env;
  }

  async fetch(request) {
    return handleLiveWebSocket(request, this.env);
  }
}

// Ilova Worker'ga WS orqali ulanadi; Worker esa API kalit bilan Gemini Live
// (BidiGenerateContent) ga ulanib, xabarlarni ikki tomonga uzatadi. API kalit
// hech qachon ilovaga chiqmaydi. App token query param (?t=) orqali tekshiriladi.
async function handleLiveWebSocket(request, env, ctx) {
  const apiKey = env.GEMINI_API_KEY;
  if (!apiKey) {
    return new Response("GEMINI_API_KEY yo'q", { status: 500 });
  }

  const url = new URL(request.url);
  const expectedToken = env.APP_TOKEN;
  if (expectedToken) {
    const provided = url.searchParams.get("t") || "";
    if (!timingSafeEqual(provided, expectedToken)) {
      return new Response("Unauthorized", { status: 401 });
    }
  }

  // API versiyasini query'dan olamiz (lv=v1alpha|v1beta) — model/versiyani
  // Worker'ni qayta deploy qilmasdan sinab ko'rish uchun. Standart: v1beta.
  const apiVersion = (url.searchParams.get("lv") || "v1beta").replace(
    /[^a-z0-9]/gi,
    ""
  );

  // Live modelini query (?lm=) yoki worker env'dan olamiz. Standart — kalit
  // uchun mavjud bo'lgan native-audio modeli. Bu ilovani QAYTA QURMASDAN
  // model almashtirishga imkon beradi: faqat Worker'ni deploy qilish kifoya.
  let modelOverride = (
    url.searchParams.get("lm") ||
    env.GEMINI_LIVE_MODEL ||
    "gemini-3.1-flash-live-preview"
  ).trim();
  if (modelOverride && !modelOverride.startsWith("models/")) {
    modelOverride = "models/" + modelOverride;
  }
  // MUHIM: Worker fetch() 'wss://' ni qabul qilmaydi — tashqi WebSocket uchun
  // 'https://' sxema + 'Upgrade: websocket' header ishlatiladi.
  let upstreamUrl =
    "https://generativelanguage.googleapis.com/ws/google.ai.generativelanguage." +
    apiVersion +
    ".GenerativeService.BidiGenerateContent?key=" +
    apiKey;

  console.log("Live WS: incoming request, upstream'ga ulanmoqda...");
  let upstream;
  try {
    let upstreamResp = await fetch(upstreamUrl, {
      headers: { Upgrade: "websocket" },
    });
    
    if (upstreamResp.status === 429 && env.FALLBACK_GEMINI_API_KEY) {
      console.log("Live WS: 429 xatosi, zaxira kalit bilan urinib ko'rilmoqda...");
      upstreamUrl = "https://generativelanguage.googleapis.com/ws/google.ai.generativelanguage." +
        apiVersion +
        ".GenerativeService.BidiGenerateContent?key=" +
        env.FALLBACK_GEMINI_API_KEY;
      upstreamResp = await fetch(upstreamUrl, {
        headers: { Upgrade: "websocket" },
      });
    }

    console.log("Live WS: upstream status =", upstreamResp.status);
    upstream = upstreamResp.webSocket;
    if (!upstream) {
      const errText = await upstreamResp.text().catch(() => "");
      console.log("Live WS: upstream webSocket yo'q:", errText.slice(0, 200));
      return new Response("Upstream WS xato: " + upstreamResp.status, {
        status: 502,
      });
    }
  } catch (e) {
    console.log("Live WS: upstream exception:", (e && e.message) || e);
    return new Response("Upstream ulanmadi: " + ((e && e.message) || e), {
      status: 502,
    });
  }

  // WebSocket proksi uchun allowHalfOpen — ikkala tomondagi close handshake'ni
  // mustaqil boshqaramiz; aks holda CF runtime 1006 abnormal closure beradi.
  const halfOpen = { allowHalfOpen: true };
  upstream.accept(halfOpen);

  const pair = new WebSocketPair();
  const client = pair[0];
  const server = pair[1];
  server.accept(halfOpen);

  // MUHIM: oddiy Worker'da fetch() javob qaytargach so'rov konteksti tugaydi va
  // uzoq davom etadigan WS oqimida isolate EVICT bo'lib "internal error" beradi.
  // ctx.waitUntil bilan konteksni WS yopilgunga qadar tirik ushlaymiz.
  let resolveClosed;
  let closed = false;
  const closedPromise = new Promise((res) => {
    resolveClosed = () => {
      if (closed) return;
      closed = true;
      res();
    };
  });
  if (ctx && typeof ctx.waitUntil === "function") {
    ctx.waitUntil(closedPromise);
  }

  function wsDataToString(data) {
    if (typeof data === "string") return data;
    if (data instanceof ArrayBuffer) {
      return new TextDecoder().decode(data);
    }
    if (ArrayBuffer.isView(data)) {
      return new TextDecoder().decode(data);
    }
    return String(data);
  }

  function safeSend(ws, data) {
    if (!ws || ws.readyState !== WebSocket.OPEN) return false;
    try {
      ws.send(data);
      return true;
    } catch (e) {
      console.log("Live WS: send xato:", (e && e.message) || e);
      return false;
    }
  }

  function closeBoth(code, reason) {
    const c = code >= 1000 && code <= 4999 ? code : 1000;
    try {
      if (upstream.readyState === WebSocket.OPEN ||
          upstream.readyState === WebSocket.CLOSING) {
        upstream.close(c, reason || "");
      }
    } catch (_) {}
    try {
      if (server.readyState === WebSocket.OPEN ||
          server.readyState === WebSocket.CLOSING) {
        server.close(c, reason || "");
      }
    } catch (_) {}
    resolveClosed();
  }

  // Ilova -> Gemini
  // Birinchi (setup) xabarida model'ni majburan to'g'ri modelga almashtiramiz,
  // shunda eski ilova buildlari ham ishlaydi.
  let setupPatched = false;
  server.addEventListener("message", (e) => {
    try {
      let data = wsDataToString(e.data);
      if (!setupPatched && modelOverride && data.includes('"setup"')) {
        try {
          const obj = JSON.parse(data);
          if (obj && obj.setup) {
            obj.setup.model = modelOverride;
            data = JSON.stringify(obj);
            setupPatched = true;
            console.log("Live WS: model =>", modelOverride, "ver =>", apiVersion);
          }
        } catch (_) {}
      }
      if (!safeSend(upstream, data)) {
        console.log("Live WS: upstream'ga yuborib bo'lmadi (readyState=" +
          upstream.readyState + ")");
      }
    } catch (err) {
      console.log("Live WS: client message xato:", (err && err.message) || err);
    }
  });
  server.addEventListener("close", (e) => {
    console.log("Live WS: client yopdi. code=", e.code, "reason=", e.reason);
    closeBoth(e.code, e.reason);
  });
  server.addEventListener("error", (e) => {
    console.log("Live WS: client error:", (e && e.message) || e);
    closeBoth(1011, "client error");
  });

  // Gemini -> ilova
  upstream.addEventListener("message", (e) => {
    if (!safeSend(server, e.data)) {
      console.log("Live WS: client'ga yuborib bo'lmadi (readyState=" +
        server.readyState + ")");
    }
  });
  upstream.addEventListener("close", (e) => {
    console.log("Live WS: GEMINI yopdi. code=", e.code, "reason=", e.reason);
    closeBoth(e.code, e.reason);
  });
  upstream.addEventListener("error", (e) => {
    console.log("Live WS: upstream error:", (e && e.message) || e);
    closeBoth(1011, "upstream error");
  });

  return new Response(null, { status: 101, webSocket: client });
}

// ─── STT (Groq Whisper) — HOZIRCHA O'CHIRILGAN ──────────────────────────────
// Pipeline qo'llab-quvvatlanmaydi — Gemini Live native audio ishlatiladi.
/*
async function handleStt(request, env, cors) {
  const groqKey = env.GROQ_API_KEY;
  if (!groqKey) {
    return json({ error: "GROQ_API_KEY worker secretlarida topilmadi" }, 500, cors);
  }

  const payload = await request.json();
  const audioBase64 = payload.audioBase64;
  const mimeType = payload.mimeType || "audio/webm";
  const language = payload.language || "de";

  if (!audioBase64) {
    return json({ error: "audioBase64 yo'q" }, 400, cors);
  }

  try {
    const audioBuffer = Uint8Array.from(atob(audioBase64), (c) => c.charCodeAt(0));
    const ext = mimeType.includes("webm")
      ? "webm"
      : mimeType.includes("ogg")
      ? "ogg"
      : mimeType.includes("wav")
      ? "wav"
      : "m4a";

    const formData = new FormData();
    formData.append("file", new Blob([audioBuffer], { type: mimeType }), `audio.${ext}`);
    formData.append("model", "whisper-large-v3");
    formData.append("language", language);
    formData.append("response_format", "json");

    const sttResp = await fetch(
      "https://api.groq.com/openai/v1/audio/transcriptions",
      {
        method: "POST",
        headers: { Authorization: `Bearer ${groqKey}` },
        body: formData,
      }
    );

    if (!sttResp.ok) {
      const errText = await sttResp.text();
      return json({ error: `Whisper xato (${sttResp.status}): ${errText.slice(0, 200)}` }, 502, cors);
    }

    const sttJson = await sttResp.json();
    return json({ text: (sttJson.text || "").trim() }, 200, cors);
  } catch (e) {
    return json({ error: (e && e.message) || String(e) }, 500, cors);
  }
}
*/

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

  const reqBody = JSON.stringify({
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
  });

  let upstream = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-goog-api-key": apiKey,
    },
    body: reqBody,
  });

  if (upstream.status === 429 && env.FALLBACK_GEMINI_API_KEY) {
    console.log("handleGeminiAudio: 429, zaxira kalitga o'tilmoqda...");
    upstream = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": env.FALLBACK_GEMINI_API_KEY,
      },
      body: reqBody,
    });
  }

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

// ─── ElevenLabs TTS — HOZIRCHA O'CHIRILGAN ──────────────────────────────────
// Pipeline qo'llab-quvvatlanmaydi — Gemini Live native audio ishlatiladi.
/*
async function handleElevenLabsTts(request, env, cors) {
  const apiKey = env.ELEVENLABS_API_KEY;
  if (!apiKey) {
    return json({ error: "ELEVENLABS_API_KEY worker secretlarida topilmadi" }, 500, cors);
  }

  const payload = await request.json();
  const rawText = payload.text || "";

  // TTS ga yuborishdan oldin LLM javobidagi barcha markerlarni olib tashlaymiz:
  // [baqirib], [krichit], [po russki], (nemis tilida), *bold*, ## sarlavhalar...
  const text = rawText
    .replace(/\[[^\]]*\]/g, '')           // [har qanday kontent] — tozalash
    .replace(/\([^)]{0,40}\)/g, '')       // (qisqa izoh) — tozalash
    .replace(/\*{1,3}([^*]+)\*{1,3}/g, '$1') // **bold**, *italic*
    .replace(/^#+\s+/gm, '')              // ## markdown sarlavhalar
    .replace(/\s{2,}/g, ' ')              // ortiqcha bo'shliqlar
    .trim();
  // ElevenLabs German voices: 
  // "Arnold" = VR6AewLTigWG4xSOukaG (erkak, energik)
  // "Adam" = pNInz6obpgDQGcFmaJgB (erkak, tabiiy)
  // "Rachel" = 21m00Tcm4TlvDq8ikWAM (ayol, yumshoq)
  const voiceId = payload.voiceId || "pNInz6obpgDQGcFmaJgB"; // Adam
  // turbo_v2_5 til majburlashni (language_code) qo'llab-quvvatlaydi.
  const modelId = payload.modelId || "eleven_turbo_v2_5";
  const languageCode = payload.languageCode || ""; // "de" | "ru" | "" (auto)

  if (!text.trim()) {
    return json({ error: "text bo'sh" }, 400, cors);
  }

  const ttsBody = {
    text: text,
    model_id: modelId,
    voice_settings: {
      stability: 0.5,
      similarity_boost: 0.75,
      style: 0.4,
      use_speaker_boost: true,
    },
  };
  // Til kodi berilgan bo'lsa, TTS'ni o'sha tilda majburlaymiz.
  if (languageCode) {
    ttsBody.language_code = languageCode;
  }

  const upstream = await fetch(
    `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`,
    {
      method: "POST",
      headers: {
        "xi-api-key": apiKey,
        "Content-Type": "application/json",
        Accept: "audio/mpeg",
      },
      body: JSON.stringify(ttsBody),
    }
  );

  if (!upstream.ok) {
    const errText = await upstream.text().catch(() => "");
    return json(
      { error: `ElevenLabs xato (${upstream.status}): ${errText.slice(0, 200)}` },
      upstream.status,
      cors
    );
  }

  const audioBuffer = await upstream.arrayBuffer();
  return new Response(audioBuffer, {
    status: 200,
    headers: { ...cors, "Content-Type": "audio/mpeg" },
  });
}
*/
