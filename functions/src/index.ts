import {onCall} from "firebase-functions/v2/https";

export const testSickBay = onCall(() => {
  return {
    severity: "low",
    eat: ["Rice", "Curd"],
    avoid: ["Junk food"],
    care: ["Take rest"],
  };
});
