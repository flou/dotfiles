-- Tabs: `cmd+arrow_right=next_tab` / `cmd+arrow_left=previous_tab`
rex.bind("cmd+right", "client.tab.next")
rex.bind("cmd+left", "client.tab.previous")

-- Move tab: `cmd+shift+arrow_right=move_tab:1` / `move_tab:-1`
rex.bind("shift+cmd+right", "client.tab.move.forward")
rex.bind("shift+cmd+left", "client.tab.move.backward")

-- Split: `cmd+d=new_split:auto`
rex.bind("cmd+d", "pane.split.auto")
