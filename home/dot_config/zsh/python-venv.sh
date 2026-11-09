# vim: set filetype=sh tabstop=2 softtabstop=2 shiftwidth=2
# shellcheck shell=zsh
function venv() {
  if command -v uv >/dev/null 2>&1; then
    uv venv
  else
    rm -rf .venv
    python -m venv .venv
  fi
  cd .
  which -a python
}

function _python-workon-cwd {
  # Walk up to the repo root (.git dir or file, covering worktrees), stopping at
  # a .venv; avoids forking `git rev-parse` on every cd.
  local PROJECT_ROOT="$PWD:A"
  while [[ "$PROJECT_ROOT" != "/" && ! -e "$PROJECT_ROOT/.venv" && ! -e "$PROJECT_ROOT/.git" ]]; do
    PROJECT_ROOT="$PROJECT_ROOT:h"
  done
  if [[ $PROJECT_ROOT == "/" ]]; then
    PROJECT_ROOT="."
  fi

  # .venv may be a name file or a directory.
  local ENV_NAME=""
  if [[ -f "$PROJECT_ROOT/.venv" ]]; then
    ENV_NAME="$(<$PROJECT_ROOT/.venv)"
  elif [[ -f "$PROJECT_ROOT/.venv/bin/activate" ]]; then
    ENV_NAME="$PROJECT_ROOT/.venv"
  elif [[ $PROJECT_ROOT != "." ]]; then
    ENV_NAME="$PROJECT_ROOT:t"
  fi

  if [[ -n $CD_VIRTUAL_ENV && "$ENV_NAME" != "$CD_VIRTUAL_ENV" ]]; then
    # Only auto-activated environments are deactivated here.
    (( $+functions[deactivate] )) && deactivate
    unset CD_VIRTUAL_ENV
  fi

  if [[ $ENV_NAME != "" ]]; then
    if [[ "$VIRTUAL_ENV" != "$WORKON_HOME/$ENV_NAME" ]]; then
      if [[ -n "$WORKON_HOME" && -e "$WORKON_HOME/$ENV_NAME/bin/activate" ]]; then
        workon "$ENV_NAME" && export CD_VIRTUAL_ENV="$ENV_NAME"
      elif [[ -e "$ENV_NAME/bin/activate" ]]; then
        source "$ENV_NAME/bin/activate" && export CD_VIRTUAL_ENV="$ENV_NAME"
      fi
    fi
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _python-workon-cwd
