# shellcheck shell=bash

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
  # Check if this is a Git repo.
  local GIT_REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"

  # Get absolute path, resolving symlinks.
  local PROJECT_ROOT="$PWD:A"
  while [[ "$PROJECT_ROOT" != "/" && ! -e "$PROJECT_ROOT/.venv" && ! -d "$PROJECT_ROOT/.git" && "$PROJECT_ROOT" != "$GIT_REPO_ROOT" ]]; do
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
    deactivate && unset CD_VIRTUAL_ENV
  fi

  if [[ $ENV_NAME != "" ]]; then
    # Activate the environment only if it is not already active.
    if [[ "$VIRTUAL_ENV" != "$WORKON_HOME/$ENV_NAME" ]]; then
      if [[ -n "$WORKON_HOME" && -e "$WORKON_HOME/$ENV_NAME/bin/activate" ]]; then
        workon "$ENV_NAME" && export CD_VIRTUAL_ENV="$ENV_NAME"
      elif [[ -e "$ENV_NAME/bin/activate" ]]; then
        source $ENV_NAME/bin/activate && export CD_VIRTUAL_ENV="$ENV_NAME"
      fi
    fi
  fi
}

# Load auto workon cwd hook.
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _python-workon-cwd
