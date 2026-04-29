#!/usr/bin/env bash
# Toggle the @claude_waiting tmux user option on the current pane's window,
# and propagate to the parent pane recorded in CLAUDE_PARENT_PANE
# (set by `bind y` in tmux.conf when launching the popup).
# Usage: tmux-waiting.sh set|clear

[ -n "$TMUX_PANE" ] || exit 0

case "${1:-}" in
  set)   set -- set-option -w -t "$TMUX_PANE" @claude_waiting 1 ;;
  clear) set -- set-option -w -u -t "$TMUX_PANE" @claude_waiting ;;
  *)     exit 1 ;;
esac
saved=("$@")

tmux "$@" 2>/dev/null

parent=$(tmux show-environment -t "$TMUX_PANE" CLAUDE_PARENT_PANE 2>/dev/null | cut -d= -f2-)
if [ -n "$parent" ]; then
  set -- "${saved[@]}"
  # swap target pane to parent
  for i in "${!saved[@]}"; do
    if [ "${saved[$i]}" = "$TMUX_PANE" ]; then
      saved[$i]="$parent"
    fi
  done
  tmux "${saved[@]}" 2>/dev/null
fi

tmux list-clients -F '#{client_name}' 2>/dev/null | while IFS= read -r c; do
  tmux refresh-client -S -t "$c" 2>/dev/null
done

exit 0
