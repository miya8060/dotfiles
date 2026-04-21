#!/bin/bash
input=$(cat)
pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$pct" ]; then
  echo "Context: ${pct}%"
else
  echo "Context: -"
fi
