#!/usr/bin/env bash
# Print a random quote for the hyprlock quote label (pango markup, wrapped).
# Reads a local cache (instant, works offline) and refreshes it in the background
# from zenquotes.io at most once a day. Cache: one "quote<TAB>author" per line.

set -uo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/quotes"
CACHE="$CACHE_DIR/quotes.tsv"
MAX_QUOTES=500
WIDTH=70

mkdir -p "$CACHE_DIR"

seed() {
  cat <<'EOF'
The best way to predict the future is to create it.	Peter Drucker
Simplicity is prerequisite for reliability.	Edsger W. Dijkstra
First, solve the problem. Then, write the code.	John Johnson
Make it work, make it right, make it fast.	Kent Beck
Premature optimization is the root of all evil.	Donald Knuth
Talk is cheap. Show me the code.	Linus Torvalds
Waste no more time arguing what a good man should be. Be one.	Marcus Aurelius
We suffer more often in imagination than in reality.	Seneca
It does not matter how slowly you go as long as you do not stop.	Confucius
The impediment to action advances action. What stands in the way becomes the way.	Marcus Aurelius
Well begun is half done.	Aristotle
The only way to do great work is to love what you do.	Steve Jobs
Programs must be written for people to read, and only incidentally for machines to execute.	Harold Abelson
Any fool can write code that a computer can understand. Good programmers write code that humans can understand.	Martin Fowler
Done is better than perfect.	Sheryl Sandberg
What we know is a drop, what we don't know is an ocean.	Isaac Newton
He who has a why to live can bear almost any how.	Friedrich Nietzsche
Luck is what happens when preparation meets opportunity.	Seneca
The obstacle is the way.	Ryan Holiday
Perplexity is the beginning of knowledge.	Kahlil Gibran
EOF
}

refresh() {
  local tmp
  tmp=$(mktemp "$CACHE_DIR/.fetch.XXXXXX") || return
  # zenquotes answers rate-limited requests with a quote authored "zenquotes.io"
  if curl -fsS --max-time 5 https://zenquotes.io/api/quotes 2>/dev/null |
    jq -r '.[] | select(.a != "zenquotes.io") | [.q, .a] | @tsv' >"$tmp" 2>/dev/null &&
    [[ -s $tmp ]]; then
    cat "$CACHE" "$tmp" | awk -F'\t' 'NF == 2 && !seen[$1]++' | tail -n "$MAX_QUOTES" >"$CACHE.new" &&
      mv "$CACHE.new" "$CACHE"
  fi
  rm -f "$tmp"
}

[[ -s $CACHE ]] || seed >"$CACHE"

# Refresh in the background (never delays the lock screen) when older than a day
if [[ -z $(find "$CACHE" -mmin -1440 2>/dev/null) ]] || [[ ! -f "$CACHE_DIR/.fetched" ]]; then
  (refresh && touch "$CACHE_DIR/.fetched") >/dev/null 2>&1 &
  disown
fi

line=$(shuf -n 1 "$CACHE")
quote=${line%%$'\t'*}
author=${line#*$'\t'}

escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }

printf '<i>“%s”</i>\n— %s\n' \
  "$(printf '%s' "$quote" | fold -s -w "$WIDTH" | sed 's/ *$//' | escape)" \
  "$(printf '%s' "$author" | escape)"
