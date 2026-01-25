# ZSH widgets and keybindings

function git-log-widget() {
  git lg
  zle reset-prompt
}
zle     -N             git-log-widget
bindkey -M emacs '\eh' git-log-widget

function open-cwd-zed-widget() {
  zed .
}
zle     -N             open-cwd-zed-widget
bindkey -M emacs '\ew' open-cwd-zed-widget

bindkey -M emacs '^[[A'     history-substring-search-up
bindkey -M emacs '^[[B'     history-substring-search-down
bindkey -M emacs '^[[3~'    delete-char
bindkey -M emacs "^[[45;5u" undo
