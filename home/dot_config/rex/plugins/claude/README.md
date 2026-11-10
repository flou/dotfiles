# Claude launcher for Rex

A Rex plugin that starts a new session running [Claude Code](https://claude.com/claude-code) and switches to it.

## Requirements

- `claude` on your login shell's `PATH`

## Install

The plugin is loaded from `init.lua`:

```lua
require("plugins.claude")
```

Then reload the configuration:

```sh
rex config reload
```

## Use

- Press <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>C</kbd>, or
- search for **New Claude Session** in the command palette, or
- run `rex do claude_open`.
