const functions = require("firebase-functions");
const {GoogleGenerativeAI} = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(
    functions.config().gemini.key,
);

exports.sickBayAdvice = functions.https.onCall(
    async (data, context) => {
      const {problems, menu} = data;

      if (!problems || !menu) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Problems and menu are required",
        );
      }

      const model = genAI.getGenerativeModel({
        model: "gemini-1.5-flash",
      });

      const prompt = `
You are a medical diet assistant.

User problems:
${problems.join(", ")}

Today's menu:
${menu.join(", ")}

Rules:
- Respond ONLY in valid JSON
- No markdown
- No explanation
- Keys must be: eat, avoid, care
- Values must be arrays of strings

JSON FORMAT:
{
  "eat": [],
  "avoid": [],
  "care": []
}
`;

      const result = await model.generateContent(prompt);
      const text = result.response.text();

      try {
        return JSON.parse(text);
      } catch (e) {
        throw new functions.https.HttpsError(
            "internal",
            "Invalid AI response",
        );
      }
    },
);
