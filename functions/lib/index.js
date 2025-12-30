"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.testSickBay = void 0;
const https_1 = require("firebase-functions/v2/https");
exports.testSickBay = (0, https_1.onCall)(() => {
    return {
        severity: "low",
        eat: ["Rice", "Curd"],
        avoid: ["Junk food"],
        care: ["Take rest"],
    };
});
//# sourceMappingURL=index.js.map