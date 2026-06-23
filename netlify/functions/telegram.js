exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body || "{}");

        const message = `
🚀 New Portfolio Visit

🌐 Page: ${body.page}
📱 Device: ${body.userAgent}
🔗 Referrer: ${body.referrer}
🕒 Time: ${new Date().toLocaleString()}
    `;

        await fetch(
            `https://api.telegram.org/bot${process.env.TELEGRAM_BOT_TOKEN}/sendMessage`,
            {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    chat_id: process.env.TELEGRAM_CHAT_ID,
                    text: message,
                }),
            }
        );

        return {
            statusCode: 200,
            body: "ok",
        };
    } catch (err) {
        return {
            statusCode: 500,
            body: err.toString(),
        };
    }
};