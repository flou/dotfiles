-- Called by plugins/ghq/init.lua once fzf has picked a repository.
--
-- Creates a session whose first terminal starts in the picked directory and
-- prints the new session's ID, which the picker then shows in the app.

local dir = rex.args.dir

if type(dir) ~= "string" or dir == "" then
    error("ghq: no directory was given", 0)
end
if dir:sub(1, 1) ~= "/" then
    error("ghq: expected an absolute path, got " .. dir, 0)
end

local name = dir:gsub("/+$", ""):match("([^/]+)$") or "repo"

local created, err = rex.call("session.create", {
    label = name,
    initial_windows = {
        {
            window_label = name,
            layout = rex.layout.block({
                flavor = "com.superlogical.terminal.shell",
                options = { cwd = dir },
            }),
        },
    },
})
if created == nil then
    error("ghq: could not create a session in " .. dir .. ": " .. tostring(err), 0)
end

print(created.session_id)
