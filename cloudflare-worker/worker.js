const MODEL = "gemini-3.8-flash";

const PROMPTS = {
  chat: "ဖြေဆိုရာတွင် ရှင်းလင်းတိကျပြီး မြန်မာဘာသာကို ဦးစားပေးပါ။",
  translate: "ဘာသာပြန်သူအဖြစ် လုပ်ဆောင်ပါ။ မူရင်းအဓိပ္ပာယ်နှင့် အသံနေအသံထားကို ထိန်းပြီး အသုံးပြုသူတောင်းဆိုသော ဘာသာသို့ ပြန်ပါ။",
  recap: "ဇာတ်လမ်းအကျဉ်းချုပ်ရေးသူအဖြစ် လုပ်ဆောင်ပါ။ ပေးထားသောအချက်အလက်အတိုင်းသာ အစဉ်လိုက်ရေးပါ။ မသိသောဖြစ်ရပ်၊ ဇာတ်ကောင်စကား သို့မဟုတ် အဆုံးသတ်ကို မတီထွင်ပါနှင့်။ Narrator အပိုင်းနှင့် ဇာတ်ကောင်စကားပြောအပိုင်းကို သီးခြားခွဲပြပါ။",
  title: "ဗီဒီယိုအတွက် မြန်မာနှင့် English ခေါင်းစဉ်၊ Description နှင့် သက်ဆိုင်ရာ hashtag များကို ဖန်တီးပါ။ မမှန်သော clickbait မသုံးပါနှင့်။",
  thumbnail: "Thumbnail အတွက် မြန်မာနှင့် English စာသားတိုများ၊ composition၊ color နှင့် visual direction ကို အကြံပြုပါ။",
  srt: "ပေးထားသော transcript ကို SRT ဖွဲ့စည်းပုံအဖြစ် ပြောင်းရန် ကူညီပါ။ အချိန်မှတ်တမ်းမပေးထားပါက timestamp မတီထွင်ဘဲ လိုအပ်ကြောင်း ရှင်းပြပါ။"
};

export default {
  async fetch(request, env) {
    const cors = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type"
    };
    if (request.method === "OPTIONS") return new Response(null, { headers: cors });
    if (request.method === "GET") {
      return Response.json({ status: "MYANMAR AI API is running" }, { headers: cors });
    }
    if (request.method !== "POST") {
      return Response.json({ error: "Method not allowed" }, { status: 405, headers: cors });
    }
    if (!env.GEMINI_API_KEY) {
      return Response.json({ error: "Server API key မသတ်မှတ်ရသေးပါ။" }, { status: 500, headers: cors });
    }

    try {
      const body = await request.json();
      const action = String(body.action || "chat");
      const input = String(body.input || body.message || "").trim();
      if (!input) return Response.json({ error: "စာသားထည့်ပေးပါ။" }, { status: 400, headers: cors });
      const instruction = PROMPTS[action] || PROMPTS.chat;

      const upstream = await fetch("https://generativelanguage.googleapis.com/v1beta/interactions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": env.GEMINI_API_KEY
        },
        body: JSON.stringify({
          model: MODEL,
          input: `${instruction}\n\nအသုံးပြုသူ၏ တောင်းဆိုချက်:\n${input}`
        })
      });

      const raw = await upstream.text();
      let data = {};
      try { data = JSON.parse(raw); } catch (_) {}

      if (!upstream.ok) {
        const status = upstream.status === 429 ? 429 : 502;
        const message = upstream.status === 429
          ? "Gemini အသုံးပြုမှုကန့်သတ်ချက် ပြည့်နေပါသည်။ ခဏစောင့်ပြီးမှ ပြန်စမ်းပါ။"
          : "AI ဝန်ဆောင်မှုမှ အမှားပြန်လာပါသည်။ ခဏနောက် ပြန်စမ်းပါ။";
        return Response.json({ error: message, upstream_status: upstream.status }, {
          status, headers: { ...cors, "Retry-After": "45" }
        });
      }

      const text = data.output_text ||
        (Array.isArray(data.outputs) ? data.outputs.map(x => x.text || "").join("\n") : "") ||
        "AI အဖြေမရရှိပါ။";
      return Response.json({ text }, { headers: cors });
    } catch (error) {
      return Response.json({ error: "Request ကို လုပ်ဆောင်မရပါ။" }, { status: 500, headers: cors });
    }
  }
};
