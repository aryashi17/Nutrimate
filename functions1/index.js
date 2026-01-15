/**
 * Firebase Cloud Function (v2): analyzeSickness
 * Nutrimate Sickbay backend
 * Node.js 20 + firebase-functions v7
 */

const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

// 🔐 Secret definition
const OPENROUTER_KEY = defineSecret("OPENROUTER_KEY");

// ───────────────────────────────────────────────

exports.analyzeSickness = onRequest(
    {
      secrets: [OPENROUTER_KEY],
      timeoutSeconds: 30,
      cors: true,
    },
    async (req, res) => {
      try {
        if (req.method !== "POST") {
          return res.status(405).json({error: "Method not allowed"});
        }

        const body = req.body || {};
        const description = body.description || "";
        const ailments = body.ailments || [];
        const nextMeal = body.nextMeal || [];

        const systemPrompt = `
You are Sickbay, a health-support assistant for the Nutrimate app.

Rules:
- You are NOT a doctor.
- Do NOT diagnose diseases.
- Do NOT prescribe medicines or dosages.
- Give general food, care, and lifestyle advice only.
- If symptoms appear serious, severity MUST be "severe".

Emergency symptoms:
chest pain, difficulty breathing, fainting, blood, severe pain.

Respond in STRICT JSON ONLY:
{
  "severity": "mild | moderate | severe",
  "eat": ["string"],
  "avoid": ["string"],
  "care": ["string"]
}
`;

        const userPrompt = `
Symptoms description:
${description || "Not provided"}

Selected ailments:
${ailments.length > 0 ? ailments.join(", ") : "None"}

Available food today:
${nextMeal.length > 0 ? nextMeal.join(", ") : "Unknown"}
`;

        // 🔥 Call OpenRouter
        const aiResponse = await axios.post(
            "https://openrouter.ai/api/v1/chat/completions",
            {
              model: "meta-llama/llama-3.3-70b-instruct:free",
              temperature: 0.2,
              messages: [
                {role: "system", content: systemPrompt},
                {role: "user", content: userPrompt},
              ],
            },
            {
              headers: {
                "Authorization": `Bearer ${OPENROUTER_KEY.value()}`,
                "Content-Type": "application/json",
              },
            },
        );

        const rawText =
        aiResponse &&
        aiResponse.data &&
        aiResponse.data.choices &&
        aiResponse.data.choices[0] &&
        aiResponse.data.choices[0].message &&
        aiResponse.data.choices[0].message.content;

        let parsed = null;
        try {
          parsed = JSON.parse(rawText);
        } catch (e) {
          console.error("JSON parse failed:", rawText);
        }

        return res.status(200).json({
          severity:
          parsed && typeof parsed.severity === "string" ?
            parsed.severity :
            "moderate",

          eat:
          parsed && Array.isArray(parsed.eat) ?
            parsed.eat :
            [],

          avoid:
          parsed && Array.isArray(parsed.avoid) ?
            parsed.avoid :
            [],

          care:
          parsed && Array.isArray(parsed.care) ?
            parsed.care :
            ["Please consult a doctor if symptoms persist"],
        });
      } catch (error) {
        console.error("Sickbay error:", error);

        return res.status(200).json({
          severity: "moderate",
          eat: [],
          avoid: [],
          care: [
            "Unable to analyze symptoms right now. Please try again later."],
        });
      }
    },
);
