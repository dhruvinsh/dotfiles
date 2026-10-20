# tmux selector powered by fzf: `t` picks a session, `t <name>` attaches/creates
function t --description 'Attach/create a tmux session (no args = fzf picker)'
    set -l session
    if test (count $argv) -eq 0
        # No args: pick a session via fzf
        set session (tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --prompt='Select tmux session: ')
        or return
    else
        set session $argv[1]
    end

    if test -n "$TMUX"
        # Already inside tmux: switch the client instead of nesting
        if test "$session" = "$(tmux display-message -p '#S')"
            echo "no-op: same session detected ($session)"
            return
        end
        tmux has-session -t=$session 2>/dev/null; or tmux new-session -d -s $session
        tmux switch-client -t $session
    else
        if tmux has-session -t=$session 2>/dev/null
            tmux attach-session -t $session
        else
            tmux new-session -s $session
        end
    end
end
