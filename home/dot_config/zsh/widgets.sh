# vim: set filetype=sh tabstop=2 softtabstop=2 shiftwidth=2
function git-log-widget() {
  git lg
  zle reset-prompt
}
zle     -N             git-log-widget
bindkey -M emacs '\eh' git-log-widget

function open-cwd-zed-widget() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local git_root=$(git rev-parse --show-toplevel)
    zed "${git_root}"
  else
    zed .
  fi
}
zle     -N             open-cwd-zed-widget
bindkey -M emacs '\ew' open-cwd-zed-widget

bindkey -M emacs '^[[A'     history-substring-search-up
bindkey -M emacs '^[[B'     history-substring-search-down
bindkey -M emacs '^[[3~'    delete-char
bindkey -M emacs "^[[45;5u" undo
