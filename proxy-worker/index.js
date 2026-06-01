export default {
  async fetch(request, env, ctx) {
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET,HEAD,POST,OPTIONS",
      "Access-Control-Max-Age": "86400",
      "Access-Control-Allow-Headers": request.headers.get("Access-Control-Request-Headers") || "*",
    };

    // Preflight (OPTIONS) so'rovlariga ruxsat berish
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    // Flutter yuborgan X-Target-Url headerini o'qish
    const targetUrl = request.headers.get("X-Target-Url");
    if (!targetUrl) {
      return new Response("Missing X-Target-Url header", { status: 400, headers: corsHeaders });
    }

    // Faqat xavfsiz provayderlarga ruxsat beramiz (open proxy bo'lib qolmasligi uchun)
    const allowedDomains = [
      "api.cerebras.ai", 
      "dashscope.aliyuncs.com",
      "dashscope-intl.aliyuncs.com",
      "api.mistral.ai", 
      "generativelanguage.googleapis.com"
    ];
    
    try {
      const targetUrlObj = new URL(targetUrl);
      if (!allowedDomains.includes(targetUrlObj.hostname)) {
         return new Response("Blocked: Domain not allowed", { status: 403, headers: corsHeaders });
      }
    } catch (e) {
      return new Response("Invalid URL format", { status: 400, headers: corsHeaders });
    }

    // So'rovni o'zgartirib qayta jo'natish
    const newRequest = new Request(targetUrl, new Request(request));
    newRequest.headers.delete("X-Target-Url");
    newRequest.headers.delete("Origin");
    newRequest.headers.delete("Referer");

    try {
      const response = await fetch(newRequest);
      const newResponse = new Response(response.body, response);
      
      // Javobga ham CORS ruxsatlarini tirkab yuborish
      Object.keys(corsHeaders).forEach(key => {
        newResponse.headers.set(key, corsHeaders[key]);
      });
      return newResponse;
    } catch (e) {
      return new Response(e.stack || e, { status: 500, headers: corsHeaders });
    }
  },
};
