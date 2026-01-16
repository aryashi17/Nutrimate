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

        const cleaned = rawText
            .replace(/```json/g, "")
            .replace(/```/g, "")
            .trim();

        let parsed = null;
        try {
          parsed = JSON.parse(cleaned);
        } catch (e) {
          console.error("JSON parse failed:", cleaned);
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

exports.analyzeFood = onRequest(
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

        const {input} = req.body || {};
        if (!input || typeof input !== "string") {
          return res.status(400).json({error: "Invalid input"});
        }

        const systemPrompt = `
You are a nutrition API.

Rules:
- You MUST return ONLY raw JSON.
- Do NOT add explanations.
- Do NOT use markdown.
- Do NOT wrap in code blocks.

If input is a common food, provide realistic nutrition values.

JSON format:
{
  "meal": "Snacks",
  "food": {
    "name": "string",
    "calories": number,
    "protein": number,
    "carbs": number,
    "fat": number
  }
}
`;


        const userPrompt = `Food item: ${input}`;

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
                "HTTP-Referer": "https://nutrimate.app",
                "X-Title": "NutriMate",
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


        let parsed;
        try {
          parsed = JSON.parse(rawText);
        } catch (e) {
          console.error("Food JSON parse failed:", rawText);
          throw new Error("Invalid AI JSON");
        }

        return res.status(200).json({
          meal: parsed && parsed.meal ? parsed.meal : "Snacks",
          food: {
            name:
              parsed &&
              parsed.food &&
              parsed.food.name ?
                parsed.food.name :
                input,

            calories:
              parsed &&
              parsed.food &&
              parsed.food.calories ?
                Number(parsed.food.calories) :
                0,

            protein:
              parsed &&
              parsed.food &&
              parsed.food.protein ?
                Number(parsed.food.protein) :
                0,

            carbs:
              parsed &&
              parsed.food &&
              parsed.food.carbs ?
                Number(parsed.food.carbs) :
                0,

            fat:
              parsed &&
              parsed.food &&
              parsed.food.fat ?
                Number(parsed.food.fat) :
                0,
          },
        });
      } catch (error) {
        console.error("analyzeFood error:", error);

        return res.status(200).json({
          meal: "Snacks",
          food: {
            name: "Unknown",
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
          },
        });
      }
    },
);
