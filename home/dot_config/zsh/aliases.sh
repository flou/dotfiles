# Aliases

alias path='echo -e ${PATH//:/\\n} | nl'

alias cm=chezmoi
alias curl="noglob curlie"
alias curlie="noglob curlie"
alias df="df -h"
alias du="du -h"
alias fd="noglob fd"
alias gg="ghq clone"
alias lg='lazygit'
alias mkdir="mkdir -p"
alias nix="noglob nix"
alias pcat="plutil -p"
alias tailf='tail -f'
alias vim=nvim
alias yz="yazi"

alias -g C='| wc -l'

if (( $+commands[bat] )); then
  alias cat='bat --style "header,plain"'
fi

# Custom functions

function mkd() {
  mkdir -p "$1" && cd "$1" || return
}

function groot() {
  cd "$(git rev-parse --show-toplevel)" || return
}

function copy() {
  if [[ -n "${1}" ]]; then
    pbcopy <"${1}"
  fi
}

function zsh-rebuild-cache() {
  rm -rf "$ZSH_CACHE_DIR"
  echo "ZSH cache cleared. Restart your shell to regenerate."
}
