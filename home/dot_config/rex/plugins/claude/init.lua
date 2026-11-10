-- Claude Code launcher for Rex.
--
-- Starts a new session running `claude` in a fixed workspace directory and
-- switches the app to it.
--
-- Load it from init.lua with:
--
--   require("plugins.claude")
--
-- The action is "claude_open" and appears in the command palette as
-- "New Claude Session". Change the binding below if cmd+shift+c is taken.

local dir = os.getenv("HOME") .. "/workspace/claude"

local function fail(message)
  error("claude: " .. message, 0)
end

rex.action({
  name = "claude_open",
  title = "New Claude Session",
  description = "Start a new session running Claude Code in " .. dir .. ".",
  category = "Sessions",
  keywords = "claude code agent ai session new open",
  run = function(ctx, args)
    -- A login shell, so claude is on PATH the same way it is in a terminal.
    local created, err = rex.call("session.create", {
      label = "claude",
      initial_windows = {
        {
          layout = rex.layout.block({
            flavor = "com.superlogical.terminal.shell",
            label = "claude",
            options = {
              command = { "sh", "-lc", "exec claude" },
              cwd = dir,
            },
          }),
        },
      },
    })
    if created == nil then
      fail("could not create a session in " .. dir .. ": " .. tostring(err))
    end

    -- Show it in the app that ran the action. From the CLI there is no app to
    -- ask, so the session is only created.
    pcall(rex.client.queue, "session.select", { session_id = created.session_id })

    return { session_id = created.session_id }
  end,
})

rex.bind("shift+cmd+c", "claude_open")
