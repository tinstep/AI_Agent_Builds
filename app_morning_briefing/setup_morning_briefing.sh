#!/bin/bash
# Setup script for Morning News Review cron job

SCRIPT_DIR="/home/cam/.openclaw/workspace/app_morning_briefing"
CONFIG_FILE="$SCRIPT_DIR/morning_news_review.sh"
CRON_JOB="30 7 * * * $SCRIPT_DIR/morning_news_review.sh >> /home/cam/morning_briefing.log 2>&1"

echo "=== Morning News Review Setup ==="
echo ""

# Check if script exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found"
    exit 1
fi

# Prompt for Telegram Bot Token
read -p "Enter your Telegram Bot Token: " bot_token
if [ -z "$bot_token" ]; then
    echo "Bot token is required"
    exit 1
fi

# Prompt for Telegram Channel ID
read -p "Enter your Telegram Channel ID (e.g., @channel or -1001234567890): " channel_id
if [ -z "$channel_id" ]; then
    echo "Channel ID is required"
    exit 1
fi

# Prompt for Tavily API Key (optional)
read -p "Enter Tavily API Key (press Enter to skip): " tavily_key

# Update the script with provided values
sed -i "s|TELEGRAM_BOT_TOKEN=\"YOUR_BOT_TOKEN_HERE\"|TELEGRAM_BOT_TOKEN=\"$bot_token\"|g" "$CONFIG_FILE"
sed -i "s|TELEGRAM_CHANNEL_ID=\"YOUR_CHANNEL_ID_HERE\"|TELEGRAM_CHANNEL_ID=\"$channel_id\"|g" "$CONFIG_FILE"

# Add Tavily key if provided
if [ -n "$tavily_key" ]; then
    # Append export to script
    echo "export TAVILY_API_KEY=\"$tavily_key\"" >> "$CONFIG_FILE"
    echo "✓ Tavily API key added"
else
    echo "⚠️  Tavily API key not set. Using fallback news sources (may be less reliable)."
fi

# Install cron job
echo ""
echo "Installing cron job to run daily at 7:30 AM..."
(crontab -l 2>/dev/null | grep -v "$CONFIG_FILE"; echo "$CRON_JOB") | crontab -

echo ""
echo "✓ Setup complete!"
echo ""
echo "Cron job installed: Daily at 7:30 AM"
echo "Log file: /home/cam/morning_briefing.log"
echo ""
echo "To test manually:"
echo "  $CONFIG_FILE"
echo ""
echo "To remove cron job later:"
echo "  crontab -e  # and delete the line for app_morning_briefing/morning_news_review.sh"
