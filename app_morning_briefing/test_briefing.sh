#!/bin/bash
# Test harness for morning briefing (dry-run: just prints the assembled message)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/morning_news_review.sh"

# Override send_telegram to just print the message
send_telegram() {
    local message
    message=$(format_briefing)
    printf '%s\n' "=== DRY RUN: assembled message ==="
    printf '%s\n' "$message"
    printf '%s\n' "=== END ==="
}

echo "=== Test 1: SEARXNG unset (default) ==="
unset SEARXNG_URL
unset TAVILY_API_KEY
main
echo ""

echo "=== Test 2: SEARXNG set to invalid endpoint (should fall back to RSS/Tavily) ==="
export SEARXNG_URL="https://httpbin.org/get"
unset TAVILY_API_KEY
main
echo ""

echo "=== Test 3: SEARXNG set to empty (same as unset) ==="
export SEARXNG_URL=""
unset TAVILY_API_KEY
main
