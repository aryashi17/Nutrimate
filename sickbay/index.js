const { onRequest } = require("firebase-functions/v2/https");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.analyzeSickness = onRequest(
  { cors: true },
  async (req, res) => {
    const description = req.body.description || "";
    const ailments = req.body.ailments || [];
    const nextMeal = req.body.nextMeal || [];

    const prompt = `
You are a health and nutrition assistant for a college mess.

Symptoms:
${description}

Selected ailments:
${ailments.join(", ")}

Next meal menu:
${nextMeal.join(", ")}

Respond ONLY in valid JSON.
No markdown. No explanation.

JSON format:
{
  "severity": "low | mild | moderate | severe",
  "eat": [],
  "avoid": [],
  "care": []
}

Rules:
- Do not prescribe medicine
- Only suggest foods from the menu
- If severity is severe, advise doctor consultation
`;

    try {
      const model = genAI.getGenerativeModel({
        model: "gemini-1.5-flash",
      });

      const result = await model.generateContent(prompt);
      const text = result.response.text();

      console.log("Gemini raw output:", text);

      const match = text.match(/\{[\s\S]*\}/);
      if (!match) {
        throw new Error("No JSON found");
      }

      const json = JSON.parse(match[0]);
      res.json(json);
    } catch (e) {
      console.error("Gemini error:", e);
      res.json({
        severity: "low",
        eat: [],
        avoid: [],
        care: ["Unable to analyze right now"],
      });
    }
  }
);
