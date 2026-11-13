# zsh-syntax-highlighting must be sourced after everything that creates ZLE
# widgets (atuin, fzf, zoxide in 50-tools), so it runs last. Styles (from the
# active chezmoi theme) are set first; the plugin reads them at load time.
if [[ -r ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.zsh/zsh-syntax-highlighting.zsh
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# vim: set filetype=zsh ts=2 sw=2:
