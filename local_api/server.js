import express from "express";
import cors from "cors";
import fetch from "node-fetch";

const app = express();
const PORT = 3000;

// Replace these with your Telegram details
const TG_TOKEN = "8394732413:AAGi3Um6-XV2QDCLCwPgm1RkvO98kfKKY4E";
const CHAT_ID = "5040690357";

// Middleware
app.use(cors());
app.use(express.json());

// POST endpoint (Flutter Web / production)
app.post("/visit", async (req, res) => {
  const ip = req.headers["x-forwarded-for"] || req.socket.remoteAddress;
  const device = req.headers["user-agent"];
  const time = new Date().toLocaleString("en-IN", { timeZone: "Asia/Kolkata" });

  const message = `👀 New Portfolio Visit
🌍 IP: ${ip}
🖥️ Device: ${device}
⏰ Time: ${time}`;

  try {
    await fetch(`https://api.telegram.org/bot${TG_TOKEN}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ chat_id: CHAT_ID, text: message }),
    });

    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// GET endpoint (for browser testing)
app.get("/visit", async (req, res) => {
  const ip = req.headers["x-forwarded-for"] || req.socket.remoteAddress;
  const device = req.headers["user-agent"];
  const time = new Date().toLocaleString("en-IN", { timeZone: "Asia/Kolkata" });

  const message = `👀 New Portfolio Visit
🌍 IP: ${ip}
🖥️ Device: ${device}
⏰ Time: ${time}`;

  try {
    await fetch(`https://api.telegram.org/bot${TG_TOKEN}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ chat_id: CHAT_ID, text: message }),
    });

    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Local Visit API running on http://localhost:${PORT}`);
});

