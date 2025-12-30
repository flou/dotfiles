#!/usr/bin/env bash

root_dir="${HOME}/workspace"
index_file=".git-directories.index"

# Uses https://github.com/sharkdp/fd instead of `find`
/opt/homebrew/bin/fd --no-ignore --hidden --glob --prune --type dir --exclude "*terragrunt-cache*" --exclude "*.terraform*" --color never '.git' "${root_dir}" --exec-batch printf '%s\n' '{//}' | sort > "${root_dir}/${index_file}"
