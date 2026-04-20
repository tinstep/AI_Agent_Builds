#!/bin/bash
# Morning News Review - Concise Daily Briefing
# Deliverable to Telegram at 7:30 AM daily

# Configuration - Fill these in
TELEGRAM_BOT_TOKEN="8716820667:AAHmx_p-FFY-AlWVmtu-GGZpIR-sfWbltaI"
TELEGRAM_CHANNEL_ID="-1003858890671"

# News topics to cover (customize as needed)
TOPICS=(
    "technology AI innovation"
    "science space discovery"
    "business economy markets"
    "world news politics"
)

# Fetch news for a topic (returns 3-5 top stories with links)
fetch_news() {
    local topic="$1"
    local output=""

    # Use Tavily if API key is available
    if [ -n "$TAVILY_API_KEY" ]; then
        local json
        json=$(curl -s -X POST "https://api.tavily.com/search" \
            -H "Content-Type: application/json" \
            -d "{\"api_key\":\"$TAVILY_API_KEY\",\"query\":\"$topic latest news today\",\"count\":5,\"search_depth\":\"basic\",\"include_answer\":false,\"include_images\":false,\"include_raw_content\":false}" \
            2>/dev/null)

        # Parse using jq if available
        if command -v jq &>/dev/null && echo "$json" | jq -e '.results' &>/dev/null; then
            echo "$json" | jq -r '.results[0:5] | map("• [" + .title + "](" + .url + ")") | .[]' 2>/dev/null
            return
        fi
    fi

    # Fallback: use Google News RSS
    local encoded_topic
    encoded_topic=$(echo "$topic" | sed 's/ /+/g')
    local rss
    rss=$(curl -s "https://news.google.com/rss/search?q=${encoded_topic}&hl=en-US&gl=US&ceid=US:en")

    # Extract titles and links
    local titles links count i title link
    titles=$(echo "$rss" | grep -o '<title>[^<]*</title>' | sed 's/<title>\(.*\)<\/title>/\1/' | sed 's/ - Google News$//' | head -5)
    links=$(echo "$rss" | grep -o '<link>[^<]*</link>' | sed 's/<link>\(.*\)<\/link>/\1/' | head -5)

    count=0
    while IFS= read -r title; do
        [ -z "$title" ] && continue
        link=$(echo "$links" | sed -n "$((count+1))p")
        if [ -n "$link" ] && [ "$link" != "https://news.google.com/rss" ]; then
            echo "• [$title]($link)"
        else
            echo "• $title"
        fi
        count=$((count + 1))
        [ $count -ge 5 ] && break
    done <<< "$titles"

    if [ $count -eq 0 ]; then
        echo "• Unable to fetch $topic headlines at this time"
    fi
}

# Format the briefing
format_briefing() {
    local date
    date=$(TZ='Australia/Melbourne' date '+%A, %B %d, %Y')

    echo "📰 *Morning Briefing - $date*"
    echo ""
    echo "🌞 *Good morning! Here's what you need to know today:*"
    echo ""

    for topic in "${TOPICS[@]}"; do
        topic_name=$(echo "$topic" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
        echo "*$topic_name*"
        fetch_news "$topic"
        echo ""
    done

    echo "_Automated briefing delivered daily at 7:30 AM_"
}

# Escape text for Telegram MarkdownV2 while preserving [text](url) links
escape_telegram_markdown() {
    local text="$1"
    # Escape special characters: _ * [ ] ( ) ~ ` > # + - = | { } . !
    # but we'll unescape [ ] ( ) used for markdown links
    text=$(printf '%s' "$text" | sed \
        -e 's/\\/\\\\/g' \
        -e 's/_/\\_/g' \
        -e 's/\*/\\*/g' \
        -e 's/~/\\~/g' \
        -e 's/`/\\`/g' \
        -e 's/>/\\>/g' \
        -e 's/#/\\#/g' \
        -e 's/+/\\+/g' \
        -e 's/-/\\-/g' \
        -e 's/?/\\?/g' \
        -e 's/!/\\!/g' \
        -e 's/\./\\\./g' \
        -e 's/:/\\:/g' \
        -e 's/{/\\{/g' \
        -e 's/}/\\}/g' \
        -e 's/|/\\|/g' \
        -e 's/=/\\=/g')
    # Unescape markdown link brackets and parens
    text=$(printf '%s' "$text" | sed \
        -e 's/\\\[/[/g' \
        -e 's/\\\]/]/g' \
        -e 's/\\\/(/g' \
        -e 's/\\\)/)/g')
    printf '%s' "$text"
}

# Send to Telegram
send_telegram() {
    local message
    message=$(format_briefing)

    # Escape for Telegram MarkdownV2
    local message_escaped
    message_escaped=$(escape_telegram_markdown "$message")

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{\"chat_id\":\"${TELEGRAM_CHANNEL_ID}\",\"text\":\"${message_escaped}\",\"parse_mode\":\"MarkdownV2\"}" \
        >/dev/null

    if [ $? -eq 0 ]; then
        echo "✓ Morning briefing sent to Telegram"
    else
        echo "✗ Failed to send to Telegram"
    fi
}

# Main
main() {
    if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ "$TELEGRAM_BOT_TOKEN" = "YOUR_BOT_TOKEN_HERE" ]; then
        echo "Error: TELEGRAM_BOT_TOKEN not configured"
        exit 1
    fi

    if [ -z "$TELEGRAM_CHANNEL_ID" ] || [ "$TELEGRAM_CHANNEL_ID" = "YOUR_CHANNEL_ID_HERE" ]; then
        echo "Error: TELEGRAM_CHANNEL_ID not configured"
        exit 1
    fi

    if [ -z "$TAVILY_API_KEY" ]; then
        echo "Warning: TAVILY_API_KEY not set. Using fallback news sources."
    fi

    send_telegram
}

main "$@"
