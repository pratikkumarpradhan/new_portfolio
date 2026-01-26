// api/visit.js
import fetch from "node-fetch";

export default async function handler(req, res) {
  const ip =
    req.headers["x-forwarded-for"]?.split(",")[0] ||
    req.socket?.remoteAddress ||
    "Unknown";

  const device = req.headers["user-agent"] || "Unknown";

  const time = new Date().toLocaleString("en-IN", { timeZone: "Asia/Kolkata" });

  const message = `👀 New Portfolio Visit
🌍 IP: ${ip}
🖥️ Device: ${device}
⏰ Time: ${time}`;

  try {
    await fetch(
      `https://api.telegram.org/bot${process.env.TG_TOKEN}/sendMessage`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          chat_id: process.env.TG_CHAT_ID,
          text: message,
        }),
      }
    );

    res.status(200).json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
}