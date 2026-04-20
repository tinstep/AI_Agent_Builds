#!/bin/bash
# Morning News Review - Concise Daily Briefing
# Sends a curated daily briefing to Telegram at 7:30 AM

# Telegram configuration
TELEGRAM_BOT_TOKEN="8716820667:AAHmx_p-FFY-AlWVmtu-GGZpIR-sfWbltaI"
TELEGRAM_CHANNEL_ID="-1003858890671"

# Optional external news source: set to a SEARXNG instance, e.g. https://searx.example
SEARXNG_URL=""

# News topics (customize as needed)
TOPICS=(
    "technology AI innovation"
    "science space discovery"
    "business economy markets"
    "world news politics"
)

# Fetch news for one topic - returns 3-5 headlines with links
fetch_news() {
    local topic="$1"
    local encoded_topic rss output title link count
    
    # Encode topic for URL using jq for robustness
    encoded_topic=$(printf "%s" "$topic" | jq -sR @uri)
    
    # Attempt SEARXNG first if configured
    if [ -n "$SEARXNG_URL" ]; then
        if command -v jq >/dev/null 2>&1; then
            local se_query_url="${SEARXNG_URL%/}/search?format=json&q=${encoded_topic}"
            se_json=$(curl -s "$se_query_url" 2>/dev/null || true)
            if [ -n "$se_json" ]; then
                headlines=$(echo "$se_json" | jq -r '.results[]? | "- [\(.title)](\(.url))"')
                if [ -n "$headlines" ]; then
                    echo "$headlines"
                    return
                fi
            fi
        fi
    fi

    # Fallback to Google News RSS
    local query_url="https://news.google.com/rss/search?q=${encoded_topic}&hl=en-US&gl=US&ceid=US:en"
    rss=$(curl -s "$query_url")

    # Use AWK to parse RSS items directly from the fetched content
    output=$(echo "$rss" | awk '
        BEGIN { RS="<item>"; FS="\n"; count = 0 }
        {
            title=""; link=""
            for(i=1; i<=NF; i++) {
                if ($i ~ /<title>/) {
                    gsub(/.*<title>|<\/title>.*/, "", $i)
                    gsub(/ - Google News$/, "", $i)
                    title = $i
                }
                if ($i ~ /<link>/) {
                    gsub(/.*<link>|<\/link>.*/, "", $i)
                    link = $i
                }
            }
            # Check whether it is a valid article (not channel meta, not Google News link) and has title/link
            if (title != "" && link != "" && link !~ /^https:\/\/news\.google\.com\//) {
                printf "• [%s](%s)\n", title, link
                count++
            }
            if (count >= 5) { exit } # Limit to 5 results
        }
    ')

    if [ -z "$output" ]; then
        echo "• Unable to fetch $topic headlines at this time."
    else
        echo "$output"
    fi
}

# Build the complete briefing message
format_briefing() {
    local date
    date=$(TZ='Australia/Melbourne' date '+%A, %B %d, %Y')

    echo "📰 Morning Briefing - $date"
    echo ""
    echo "🌞 Good morning! Here's what you need to know today:"
    echo ""

    for topic in "${TOPICS[@]}"; do
        topic_name=$(echo "$topic" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
        echo "*$topic_name*"
        fetch_news "$topic"
        echo ""
    done

    echo "─"
    echo "Automated briefing • Delivered daily at 7:30 AM"
}

# Escape for Telegram MarkdownV2 but keep markdown links
escape_telegram() {
    local text="$1"
    text=${text//\\/\\\\}
    text=${text//_/\\_}
    text=${text//\*/\\*}
    text=${text//~/\\~}
    text=${text//\`/\\\`}
    text=${text//\>/\\>}
    text=${text//#/\\#}
    text=${text//+/\\+}
    text=${text//-/\\-}
    text=${text//\?/\\?}
    text=${text//!/\\!}
    text=${text//./\\.}
    text=${text//:/\\:}
    text=${text//\{/\\{}
    text=${text//\}/\\}}
    text=${text//|/\\|}
    text=${text//=/\\=}
    
    text=${text//\\\[/[}
    text=${text//\\\]/]}
    text=${text//\\\(/(}
    text=${text//\\\)/)}
    
    printf '%s' "$text"
}

# Send to Telegram
send_telegram() {
    local message escaped
    message=$(format_briefing)
    escaped=$(escape_telegram "$message")

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{\"chat_id\":\"${TELEGRAM_CHANNEL_ID}\",\"text\":\"${escaped}\",\"parse_mode\":\"MarkdownV2\"}" \
        >/dev/null

    if [ $? -eq 0 ]; then
        echo "✓ Morning briefing sent to Telegram"
    else
        echo "✗ Failed to send to Telegram"
    fi
}

# Entry point
main() {
    [ -z "$TELEGRAM_BOT_TOKEN" ] && { echo "Error: TELEGRAM_BOT_TOKEN not configured" >&2; exit 1; }
    [ -z "$TELEGRAM_CHANNEL_ID" ] && { echo "Error: TELEGRAM_CHANNEL_ID not configured" >&2; exit 1; }

    send_telegram
}

main
