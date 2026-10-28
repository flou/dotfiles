-- Tabs: `cmd+arrow_right=next_tab` / `cmd+arrow_left=previous_tab`
rex.bind("cmd+right", "client.tab.next")
rex.bind("cmd+left", "client.tab.previous")

-- Move tab: `cmd+shift+arrow_right=move_tab:1` / `move_tab:-1`
rex.bind("shift+cmd+right", "client.tab.move.forward")
rex.bind("shift+cmd+left", "client.tab.move.backward")

-- Split: `cmd+d=new_split:auto`
rex.bind("cmd+d", "pane.split.auto")

rex.bind("shift+cmd+r", "client.config.reload")
rex.bind("shift+enter", "com.superlogical.terminal.write", { data = "\27\r" })
rex.bind("cmd+k", "com.superlogical.terminal.clear")

rex.bind("shift+up", "client.prompt.previous")
rex.bind("shift+down", "client.prompt.next")

local function ignore()
    return true
end
rex.bind("cmd+enter", ignore)

-- Pick a ghq repository in a floating window and open a session there.
require("plugins.ghq")
