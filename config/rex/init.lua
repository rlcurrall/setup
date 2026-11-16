-- Migrated from zellij/config.kdl; cmd+k keeps Rex's session picker.
-- Terminal typing is the default (the source's initial locked state).
-- Ctrl+g opens command mode, containing the source's normal-mode shortcuts.
-- Returning to the source's locked state exits all Rex modes.
-- Unsupported scroll/session workflows and unreachable modes are omitted.
-- Alt+Left/Right keep Rex's shell word navigation outside command mode.
-- Shifted resize bindings are omitted: negative resize amounts are unverified.

rex.mode("command", { exclusive = true })
rex.mode("pane", { exclusive = true })
rex.mode("tab", { exclusive = true })
rex.mode("resize", { exclusive = true })
rex.mode("move", { exclusive = true })

rex.action{
  name  = "then_typing",
  title = "Run an action and return to terminal typing",
  args  = { action = "string", args = "object?" },
  run   = function(ctx, args)
    rex.client.queue(args.action, args.args or {})
    rex.client.queue("client.mode.exit_all")
  end,
}

-- zellij/config.kdl:24
rex.bind("ctrl+g", "client.mode.enter", { name = "command" })
-- zellij/config.kdl:27
rex.bind("pane/left", "pane.focus", { direction = "left" })
-- zellij/config.kdl:28
rex.bind("pane/down", "pane.focus", { direction = "down" })
-- zellij/config.kdl:29
rex.bind("pane/up", "pane.focus", { direction = "up" })
-- zellij/config.kdl:30
rex.bind("pane/right", "pane.focus", { direction = "right" })
-- zellij/config.kdl:32
rex.bind("pane/d", "then_typing", { action = "pane.split", args = { direction = "down" } })
-- zellij/config.kdl:34
rex.bind("pane/f", "then_typing", { action = "pane.zoom" })
-- zellij/config.kdl:35
rex.bind("pane/h", "pane.focus", { direction = "left" })
-- zellij/config.kdl:36
rex.bind("pane/j", "pane.focus", { direction = "down" })
-- zellij/config.kdl:37
rex.bind("pane/k", "pane.focus", { direction = "up" })
-- zellij/config.kdl:38
rex.bind("pane/l", "pane.focus", { direction = "right" })
-- zellij/config.kdl:39
rex.bind("pane/n", "then_typing", { action = "pane.split", args = { direction = "auto" } })
-- zellij/config.kdl:40
rex.bind("pane/p", "client.mode.enter", { name = "command" })
-- zellij/config.kdl:41
rex.bind("pane/r", "then_typing", { action = "pane.split", args = { direction = "right" } })
-- zellij/config.kdl:43
rex.bind("pane/x", "then_typing", { action = "pane.close" })
-- zellij/config.kdl:45
rex.bind("pane/tab", "pane.focus_next")
-- zellij/config.kdl:48
rex.bind("tab/left", "client.tab.previous")
-- zellij/config.kdl:49
rex.bind("tab/down", "client.tab.next")
-- zellij/config.kdl:50
rex.bind("tab/up", "client.tab.previous")
-- zellij/config.kdl:51
rex.bind("tab/right", "client.tab.next")
-- zellij/config.kdl:52
rex.bind("tab/1", "then_typing", { action = "client.tab.goto", args = { index = 1 } })
-- zellij/config.kdl:53
rex.bind("tab/2", "then_typing", { action = "client.tab.goto", args = { index = 2 } })
-- zellij/config.kdl:54
rex.bind("tab/3", "then_typing", { action = "client.tab.goto", args = { index = 3 } })
-- zellij/config.kdl:55
rex.bind("tab/4", "then_typing", { action = "client.tab.goto", args = { index = 4 } })
-- zellij/config.kdl:56
rex.bind("tab/5", "then_typing", { action = "client.tab.goto", args = { index = 5 } })
-- zellij/config.kdl:57
rex.bind("tab/6", "then_typing", { action = "client.tab.goto", args = { index = 6 } })
-- zellij/config.kdl:58
rex.bind("tab/7", "then_typing", { action = "client.tab.goto", args = { index = 7 } })
-- zellij/config.kdl:59
rex.bind("tab/8", "then_typing", { action = "client.tab.goto", args = { index = 8 } })
-- zellij/config.kdl:60
rex.bind("tab/9", "then_typing", { action = "client.tab.goto", args = { index = 9 } })
-- zellij/config.kdl:63
rex.bind("tab/b", "then_typing", { action = "pane.move_to_new_tab" })
-- zellij/config.kdl:64
rex.bind("tab/h", "client.tab.previous")
-- zellij/config.kdl:65
rex.bind("tab/j", "client.tab.next")
-- zellij/config.kdl:66
rex.bind("tab/k", "client.tab.previous")
-- zellij/config.kdl:67
rex.bind("tab/l", "client.tab.next")
-- zellij/config.kdl:68
rex.bind("tab/n", "then_typing", { action = "client.tab.new" })
-- zellij/config.kdl:71
rex.bind("tab/t", "client.mode.enter", { name = "command" })
-- zellij/config.kdl:72
rex.bind("tab/x", "then_typing", { action = "client.tab.close" })
-- zellij/config.kdl:76
rex.bind("resize/left", "pane.resize", { direction = "left" })
-- zellij/config.kdl:77
rex.bind("resize/down", "pane.resize", { direction = "down" })
-- zellij/config.kdl:78
rex.bind("resize/up", "pane.resize", { direction = "up" })
-- zellij/config.kdl:79
rex.bind("resize/right", "pane.resize", { direction = "right" })
-- zellij/config.kdl:87
rex.bind("resize/h", "pane.resize", { direction = "left" })
-- zellij/config.kdl:88
rex.bind("resize/j", "pane.resize", { direction = "down" })
-- zellij/config.kdl:89
rex.bind("resize/k", "pane.resize", { direction = "up" })
-- zellij/config.kdl:90
rex.bind("resize/l", "pane.resize", { direction = "right" })
-- zellij/config.kdl:91
rex.bind("resize/r", "client.mode.enter", { name = "command" })
-- zellij/config.kdl:94
rex.bind("move/left", "pane.move", { direction = "left" })
-- zellij/config.kdl:95
rex.bind("move/down", "pane.move", { direction = "down" })
-- zellij/config.kdl:96
rex.bind("move/up", "pane.move", { direction = "up" })
-- zellij/config.kdl:97
rex.bind("move/right", "pane.move", { direction = "right" })
-- zellij/config.kdl:98
rex.bind("move/h", "pane.move", { direction = "left" })
-- zellij/config.kdl:99
rex.bind("move/j", "pane.move", { direction = "down" })
-- zellij/config.kdl:100
rex.bind("move/k", "pane.move", { direction = "up" })
-- zellij/config.kdl:101
rex.bind("move/l", "pane.move", { direction = "right" })
-- zellij/config.kdl:102
rex.bind("move/m", "client.mode.enter", { name = "command" })
-- zellij/config.kdl:153
rex.bind("command/alt+left", "pane.focus", { direction = "left" })
-- zellij/config.kdl:154
rex.bind("alt+down", "pane.focus", { direction = "down" })
rex.bind("command/alt+down", "pane.focus", { direction = "down" })
-- zellij/config.kdl:155
rex.bind("alt+up", "pane.focus", { direction = "up" })
rex.bind("command/alt+up", "pane.focus", { direction = "up" })
-- zellij/config.kdl:156
rex.bind("command/alt+right", "pane.focus", { direction = "right" })
-- zellij/config.kdl:163
rex.bind("alt+h", "pane.focus", { direction = "left" })
rex.bind("command/alt+h", "pane.focus", { direction = "left" })
-- zellij/config.kdl:164
rex.bind("alt+i", "client.tab.move", { direction = "backward" })
rex.bind("command/alt+i", "client.tab.move", { direction = "backward" })
-- zellij/config.kdl:165
rex.bind("alt+j", "pane.focus", { direction = "down" })
rex.bind("command/alt+j", "pane.focus", { direction = "down" })
-- zellij/config.kdl:166
rex.bind("alt+k", "pane.focus", { direction = "up" })
rex.bind("command/alt+k", "pane.focus", { direction = "up" })
-- zellij/config.kdl:167
rex.bind("alt+l", "pane.focus", { direction = "right" })
rex.bind("command/alt+l", "pane.focus", { direction = "right" })
-- zellij/config.kdl:168
rex.bind("alt+n", "pane.split", { direction = "auto" })
rex.bind("command/alt+n", "pane.split", { direction = "auto" })
-- zellij/config.kdl:169
rex.bind("alt+o", "client.tab.move", { direction = "forward" })
rex.bind("command/alt+o", "client.tab.move", { direction = "forward" })
-- zellij/config.kdl:172
rex.bind("command/ctrl+g", "client.mode.exit_all")
rex.bind("pane/ctrl+g", "client.mode.exit_all")
rex.bind("tab/ctrl+g", "client.mode.exit_all")
rex.bind("resize/ctrl+g", "client.mode.exit_all")
rex.bind("move/ctrl+g", "client.mode.exit_all")
-- zellij/config.kdl:176
rex.bind("command/enter", "client.mode.exit_all")
rex.bind("pane/enter", "client.mode.exit_all")
rex.bind("tab/enter", "client.mode.exit_all")
rex.bind("resize/enter", "client.mode.exit_all")
rex.bind("move/enter", "client.mode.exit_all")
-- zellij/config.kdl:179
rex.bind("command/esc", "client.mode.exit_all")
rex.bind("pane/esc", "client.mode.exit_all")
rex.bind("tab/esc", "client.mode.exit_all")
rex.bind("resize/esc", "client.mode.exit_all")
rex.bind("move/esc", "client.mode.exit_all")
-- zellij/config.kdl:182
rex.bind("command/m", "client.mode.enter", { name = "move" })
rex.bind("pane/m", "client.mode.enter", { name = "move" })
rex.bind("tab/m", "client.mode.enter", { name = "move" })
rex.bind("resize/m", "client.mode.enter", { name = "move" })
-- zellij/config.kdl:188
rex.bind("command/t", "client.mode.enter", { name = "tab" })
rex.bind("pane/t", "client.mode.enter", { name = "tab" })
rex.bind("resize/t", "client.mode.enter", { name = "tab" })
rex.bind("move/t", "client.mode.enter", { name = "tab" })
-- zellij/config.kdl:194
rex.bind("command/p", "client.mode.enter", { name = "pane" })
rex.bind("resize/p", "client.mode.enter", { name = "pane" })
rex.bind("tab/p", "client.mode.enter", { name = "pane" })
-- zellij/config.kdl:197
rex.bind("command/r", "client.mode.enter", { name = "resize" })
rex.bind("move/r", "client.mode.enter", { name = "resize" })
