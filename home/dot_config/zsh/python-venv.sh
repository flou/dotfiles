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
  # Walk up from the current directory looking for a .venv, stopping at the
  # repository root (a .git directory or file, which covers worktrees and
  # submodules). This avoids forking `git rev-parse` on every cd.
  local PROJECT_ROOT="$PWD:A"
  while [[ "$PROJECT_ROOT" != "/" && ! -e "$PROJECT_ROOT/.venv" && ! -e "$PROJECT_ROOT/.git" ]]; do
    PROJECT_ROOT="$PROJECT_ROOT:h"
  done
  if [[ $PROJECT_ROOT == "/" ]]; then
    PROJECT_ROOT="."
  fi

  # Check for virtualenv name override.
  local ENV_NAME=""
  if [[ -f "$PROJECT_ROOT/.venv" ]]; then
    ENV_NAME="$(<$PROJECT_ROOT/.venv)"
  elif [[ -f "$PROJECT_ROOT/.venv/bin/activate" ]]; then
    ENV_NAME="$PROJECT_ROOT/.venv"
  elif [[ $PROJECT_ROOT != "." ]]; then
    ENV_NAME="$PROJECT_ROOT:t"
  fi

  if [[ -n $CD_VIRTUAL_ENV && "$ENV_NAME" != "$CD_VIRTUAL_ENV" ]]; then
    # We've just left the repo, deactivate the environment.
    # Note: this only happens if the virtualenv was activated automatically.
    (( $+functions[deactivate] )) && deactivate
    unset CD_VIRTUAL_ENV
  fi

  if [[ $ENV_NAME != "" ]]; then
    # Activate the environment only if it is not already active.
    if [[ "$VIRTUAL_ENV" != "$WORKON_HOME/$ENV_NAME" ]]; then
      if [[ -n "$WORKON_HOME" && -e "$WORKON_HOME/$ENV_NAME/bin/activate" ]]; then
        workon "$ENV_NAME" && export CD_VIRTUAL_ENV="$ENV_NAME"
      elif [[ -e "$ENV_NAME/bin/activate" ]]; then
        source "$ENV_NAME/bin/activate" && export CD_VIRTUAL_ENV="$ENV_NAME"
      fi
    fi
  fi
}

# Load auto workon cwd hook.
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _python-workon-cwd
