# Shell options, history and key bindings.

# Persistent history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY

# Configure the push directory stack (most people don't need this)
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Move to directories without cd
setopt autocd

# Emacs keybindings
bindkey -e

# Navigation keys (oh-my-zsh used to bind these). Both the normal and the
# application-mode sequences, so they work in every terminal and under tmux.
bindkey -M emacs '^[[H' beginning-of-line # Home
bindkey -M emacs '^[OH' beginning-of-line
bindkey -M emacs '^[[1~' beginning-of-line
bindkey -M emacs '^[[F' end-of-line # End
bindkey -M emacs '^[OF' end-of-line
bindkey -M emacs '^[[4~' end-of-line
bindkey -M emacs '^[[3~' delete-char          # Delete
bindkey -M emacs '^[[3;5~' kill-word          # Ctrl-Delete
bindkey -M emacs '^[[1;5C' forward-word       # Ctrl-Right
bindkey -M emacs '^[[1;5D' backward-word      # Ctrl-Left
bindkey -M emacs '^[[Z' reverse-menu-complete # Shift-Tab

# vim: set filetype=zsh ts=2 sw=2:
