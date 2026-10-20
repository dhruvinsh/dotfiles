# Completion system. Must run after every fpath change (see ~/.zshrc) and
# before tool inits that call `compdef` (zoxide, mise, …).
#
# A full `compinit` (security audit + rescanning fpath) costs ~150 ms, so do it
# at most once a day and trust the cached dump otherwise. New completion files
# are therefore picked up within 24h — or immediately after `rm ~/.zcompdump`.

autoload -Uz compinit
() {
  local dump=${ZDOTDIR:-$HOME}/.zcompdump
  # Glob qualifiers aren't expanded inside [[ ]], so test staleness via an array.
  local -a stale=($dump(N.mh+24))
  if [[ ! -s $dump ]] || (($#stale)); then
    compinit -d "$dump"
    # compinit leaves the dump untouched when nothing changed; bump its mtime
    # so the next shell takes the fast path.
    touch "$dump"
  else
    compinit -C -d "$dump"
  fi
  # Byte-compile the dump; `source` prefers a newer .zwc automatically.
  [[ $dump.zwc -nt $dump ]] || zcompile "$dump"
}

# vim: set filetype=zsh ts=2 sw=2:
