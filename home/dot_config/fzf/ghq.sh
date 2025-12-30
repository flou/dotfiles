__fzf_defaults() {
  printf '%s\n' "--height -40% --min-height 20+ --bind=ctrl-z:ignore $1"
  printf '%s\n' "${FZF_DEFAULT_OPTS-} $2"
}

fzf-ghq-widget() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(
    FZF_DEFAULT_COMMAND="ghq list --full-path" \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "--cycle +m") \
    fzf < /dev/tty)"

  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi

  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="builtin cd -- ${(q)dir:a}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}

# ALT-S - cd into the selected git project
zle     -N             fzf-ghq-widget
bindkey -M emacs '\es' fzf-ghq-widget
