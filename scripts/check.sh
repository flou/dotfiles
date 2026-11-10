#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_dir/home"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

personal_data='{"work":false,"my":{"name":"Test User","email":"test@example.com","workspace":"/tmp"}}'
work_data='{"work":true,"my":{"name":"Test User","email":"test@example.com","work_email":"work@example.com","work_git_forge":"example.com","workspace":"/tmp"}}'

die() {
  echo "check: $*" >&2
  exit 1
}

command -v chezmoi >/dev/null 2>&1 || die "chezmoi is required"
command -v zsh >/dev/null 2>&1 || die "zsh is required"

render() {
  local template=$1 data=$2 output=$3
  chezmoi execute-template --source "$source_dir" --override-data "$data" \
    < "$source_dir/$template" > "$output"
}

has_tomllib=false
if command -v python3 >/dev/null 2>&1 &&
  python3 -c 'import tomllib' >/dev/null 2>&1; then
  has_tomllib=true
fi

check_toml() {
  local file=$1
  if $has_tomllib; then
    python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$file"
  fi
}

check_yaml() {
  local file=$1
  if command -v python3 >/dev/null 2>&1 &&
    python3 -c 'import yaml' >/dev/null 2>&1; then
    python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1]))' "$file"
  fi
}

# Every template must render and apply cleanly in both modes. chezmoi skips
# templates that call a secret manager, which keeps this usable in CI.
mkdir -p "$tmp/dest"
for data in "$personal_data" "$work_data"; do
  chezmoi apply --dry-run --skip-secrets --source "$source_dir" \
    --destination "$tmp/dest" --override-data "$data" \
    --refresh-externals=never --no-tty --no-pager
done

# Render the templates that do not need a secret manager.
render dot_zshrc.tmpl "$personal_data" "$tmp/zshrc"
render dot_zprofile.tmpl "$personal_data" "$tmp/zprofile"
render dot_config/mise/config.toml.tmpl "$personal_data" "$tmp/mise-personal.toml"
render dot_config/mise/config.toml.tmpl "$work_data" "$tmp/mise-work.toml"
render dot_config/starship.toml.tmpl "$personal_data" "$tmp/starship-personal.toml"
render dot_config/starship.toml.tmpl "$work_data" "$tmp/starship-work.toml"
render dot_config/direnv/direnv.toml.tmpl "$work_data" "$tmp/direnv-work.toml"
render dot_config/ripgrep/rc.tmpl "$personal_data" "$tmp/ripgrep-rc"
render dot_config/k9s/config.yaml.tmpl "$personal_data" "$tmp/k9s.yaml"
render private_dot_ssh/config.tmpl "$personal_data" "$tmp/ssh-config"
render .chezmoiignore "$personal_data" "$tmp/ignore-personal"
render .chezmoiignore "$work_data" "$tmp/ignore-work"

# Shell syntax.
zsh -n "$tmp/zshrc"
zsh -n "$tmp/zprofile"
zsh -n "$source_dir/dot_zshenv"
for file in "$source_dir"/dot_config/zsh/*.sh; do
  zsh -n "$file"
done

# Structured config.
for file in "$tmp"/*.toml; do
  check_toml "$file"
done
check_yaml "$tmp/k9s.yaml"
check_yaml "$source_dir/dot_config/lazygit/config.yml"

# Work tools must be under [tools], not swallowed by [history].
if $has_tomllib; then
  python3 - "$tmp/mise-work.toml" <<'PY'
import sys
import tomllib

with open(sys.argv[1], "rb") as fh:
    config = tomllib.load(fh)
missing = {"kubectl", "gcloud", "aws-cli"} - set(config.get("tools", {}))
if missing:
    raise SystemExit(f"work tools missing from [tools]: {sorted(missing)}")
PY
fi

# Python launcher syntax.
if command -v python3 >/dev/null 2>&1; then
  python3 - "$source_dir/dot_local/bin/private_executable_passw" <<'PY'
import ast
import pathlib
import sys

ast.parse(pathlib.Path(sys.argv[1]).read_text(), filename=sys.argv[1])
PY
fi

# Bash scripts.
if command -v shellcheck >/dev/null 2>&1 &&
  shellcheck --version >/dev/null 2>&1; then
  shellcheck -s bash \
    "$repo_dir/scripts/check.sh" \
    "$source_dir/dot_local/bin/private_executable_git-web" \
    "$source_dir/dot_local/bin/private_executable_seecert"
else
  echo "check: shellcheck not available, skipping bash lint" >&2
fi

# No template markers should survive rendering.
if grep -R -n '{{' "$tmp" >/dev/null 2>&1; then
  grep -R -n '{{' "$tmp" >&2 || true
  die "unrendered template markers found"
fi

echo "check: ok"
