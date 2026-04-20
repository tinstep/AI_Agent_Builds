# Morning News Review System

A concise daily news briefing delivered to Telegram at 7:30 AM every day.

## Features

- **Concise format**: Scannable bullet points across multiple topics
- **Customizable topics**: Edit the TOPICS array to focus on your interests
- **Clean delivery**: Markdown-formatted message in Telegram
- **Automated scheduling**: Runs daily via cron at 7:30 AM

## Setup

### 1. Get API Keys

**News source** (choose one):
- **SEARXNG** (recommended, self-hosted or trusted instance): set `SEARXNG_URL` to your instance base URL, e.g. `https://searx.example`
- **Tavily API** (external service): visit https://tavily.com, sign up, and get an API key from the dashboard (free tier available)

Note: If `SEARXNG_URL` is set, the script will use it first; otherwise it falls back to Tavily (if key present) or Google News RSS.

**Telegram Bot**:
- Message @BotFather on Telegram
- Use `/newbot` to create a bot
- Copy the bot token provided
- Add the bot to your Telegram channel as an admin

### 2. Configure

Edit `app_morning_briefing/morning_news_review.sh` and set:

```bash
TELEGRAM_BOT_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
TELEGRAM_CHANNEL_ID="@yourchannel"  # or -1001234567890
TAVILY_API_KEY="tvly-xxxxxxxxxxxxx"  # export as env var or add to script
```

### 3. Customize Topics

Modify the `TOPICS` array in the script:

```bash
TOPICS=(
    "technology AI innovation"
    "science space discovery"
    "business economy markets"
    "world news politics"
    "sports"                # add your interests
    "environment climate"
)
```

### 4. Schedule Delivery

Add to your crontab (`crontab -e`):

```cron
30 7 * * * /home/cam/.openclaw/workspace/app_morning_briefing/morning_news_review.sh >> /home/cam/morning_briefing.log 2>&1
```

This runs daily at 7:30 AM in your local timezone.

## Manual Testing

Run manually to verify:

```bash
export TAVILY_API_KEY="your-key-here"
./app_morning_briefing/morning_news_review.sh
```

Check your Telegram channel for the message.

## Notes

- The script uses Tavily's search API to fetch current headlines
- News is limited to the last 24 hours
- MarkdownV2 escaping ensures Telegram renders formatting correctly
- Logs are appended to `morning_briefing.log` for troubleshooting

## Dependencies

- `curl` (for API requests)
- `jq` (optional, for better JSON parsing - currently not installed, script uses grep fallback)
- Internet connection at runtime

## Customization Ideas

- Add weather/local news for Melbourne
- Include specific sources: "site:theguardian.com technology"
- Add stock market summaries
- Include your calendar events for the day
- Integrate with your Obsidian daily notes

Need the Telegram Channel ID? Run the bot once and check the API response or add the bot to your channel and use a tool like @getidsbot.

Enjoy your morning briefing!
