# vim: set filetype=sh tabstop=2 softtabstop=2 shiftwidth=2
# eza aliases. Sourced eagerly from ~/.zshrc; pure zsh so there are no forks.

if (($+commands[eza])); then
  () {
    local -a ignore_lines
    ignore_lines=("${(@f)$(<"${XDG_CONFIG_HOME}/eza/ignore")}")
    ignore_lines=(${ignore_lines:#})
    local IFS='|'
    local ignore_glob="${ignore_lines[*]}"
    alias ls="eza -a -s type --ignore-glob='${ignore_glob}' --group-directories-first"
    alias l="eza -la -s type --ignore-glob='${ignore_glob}' --group-directories-first"
    alias tree="eza -lT --hyperlink --ignore-glob='${ignore_glob}' --group-directories-first"
  }
fi
