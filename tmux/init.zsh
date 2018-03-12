#!bin/zsh
[ -z "$TMUX"  ] && { tmux attach 2>/dev/null || tmux new-session 2>/dev/null && exit;}
