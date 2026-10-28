# ghq picker for Rex

A Rex plugin that lists your [ghq](https://github.com/x-motemen/ghq) repositories
in a floating window and starts a new session in the one you pick with Enter.

## Requirements

- `ghq` and `fzf` on your `PATH`
- Rex Beta with floating layers (`session.new_layer`)

## Install

The plugin is loaded from `init.lua`:

```lua
require("plugins.ghq")
```

Then reload the configuration:

```sh
rex config reload
```

## Use

- Press <kbd>Cmd</kbd>+<kbd>O</kbd>, or
- search for **Open ghq Repository…** in the command palette, or
- run `rex do ghq_open`.

Type to filter, Enter to open, Esc to cancel.
