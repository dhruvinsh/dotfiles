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

# vim: set filetype=zsh ts=2 sw=2:
