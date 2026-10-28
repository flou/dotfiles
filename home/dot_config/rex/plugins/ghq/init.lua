-- ghq picker for Rex.
--
-- Lists the repositories from `ghq list --full-path` in a floating window and
-- opens a new session in the one picked with Enter. Requires `ghq` and `fzf`.
--
-- Load it from init.lua with:
--
--   require("plugins.ghq")
--
-- The action is "ghq_open" and appears in the command palette as
-- "Open ghq Repository…". Change the binding below if cmd+shift+g is taken.

local shell = "com.superlogical.terminal.shell"

-- The directory this file lives in, so the picker can find open.lua beside it.
local plugin_dir = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("/init%.lua$", "")

local function fail(message)
    error("ghq: " .. message, 0)
end

-- Rex's own PATH is often smaller than the one a terminal gets, so run the
-- checks and the picker through the user's login shell.
local function login_shell()
    for _, candidate in ipairs({ os.getenv("SHELL"), "/bin/zsh", "/bin/bash", "/bin/sh" }) do
        if type(candidate) == "string" and candidate ~= "" then
            local file = io.open(candidate, "r")
            if file ~= nil then
                file:close()
                return candidate
            end
        end
    end
    return "/bin/sh"
end

local function quote(text)
    return "'" .. tostring(text):gsub("'", "'\\''") .. "'"
end

-- The client to show the new session in: the one that ran the action when it
-- is the app itself, otherwise the app attached to the session.
local function app_client(session_id, preferred)
    local listed = rex.call("client.list")
    local clients = listed and listed.clients or {}

    local function is_app(client)
        return client.info ~= nil and client.info.kind == "app"
    end

    local function attached(client)
        for _, id in ipairs(client.session_ids or {}) do
            if id == session_id then
                return true
            end
        end
        return false
    end

    for _, client in ipairs(clients) do
        if client.client_id == preferred and is_app(client) then
            return client.client_id
        end
    end

    local candidates = {}
    local apps = {}
    for _, client in ipairs(clients) do
        if is_app(client) then
            apps[#apps + 1] = client.client_id
            if attached(client) then
                candidates[#candidates + 1] = client.client_id
            end
        end
    end

    if #candidates == 1 then
        return candidates[1]
    end
    if #candidates == 0 and #apps == 1 then
        return apps[1]
    end
    return nil
end

rex.action({
    name = "ghq_open",
    title = "Open ghq Repository…",
    description = "Pick a repository from ghq in a floating window and start a new session in it.",
    category = "Sessions",
    keywords = "ghq git repository repo project session open picker",
    run = function(ctx, args)
        if ctx.session_id == nil then
            fail("no session to open the picker in")
        end

        local sh = login_shell()

        local function run(command, timeout)
            return rex.exec({ sh, "-l", "-c", command }, { timeout = timeout })
        end

        local function have(program)
            local result = run("command -v " .. program, 10)
            return result ~= nil and result.ok
        end

        if not have("ghq") then
            fail("ghq was not found on PATH")
        end
        if not have("fzf") then
            fail("fzf was not found on PATH")
        end

        -- Fail before showing the window when there is nothing to pick from.
        local repos = run("ghq list --full-path", 15)
        if repos == nil then
            fail("could not run ghq list")
        end
        if not repos.ok then
            local why = repos.stderr ~= "" and repos.stderr or ("exit status " .. repos.code)
            fail("ghq list failed: " .. why)
        end
        if repos.stdout:match("^%s*$") then
            fail("no repositories found; add one with `ghq get`")
        end

        local script = plugin_dir .. "/open.lua"
        local client = app_client(ctx.session_id, ctx.client_id) or ""

        -- fzf reads the full paths, so Enter prints the directory to open.
        -- open.lua creates the session and prints its ID, then the client is
        -- asked to show it. The window closes once this script exits.
        local pick = table.concat({
            "dir=$(ghq list --full-path | fzf --ansi --reverse --walker=dir,follow,hidden --scheme=path)",
            '[ -n "$dir" ] || exit 0',
            "sid=$(rex do " .. quote(script) .. ' dir="$dir") || exit 1',
            '[ -n "$sid" ] || exit 1',
            "if [ -n " .. quote(client) .. " ]; then",
            "  if ! rex -C " .. quote(client) .. ' do session.select session_id="$sid" >/dev/null 2>&1; then',
            '    printf "\\nCreated a session in %s, but Rex did not switch to it.\\n" "$dir"',
            '    printf "Turn on Remote Control in Rex > Settings > Rex Server to switch automatically.\\n"',
            '    printf "\\nPress Return to close this window. "',
            "    read -r _",
            "  fi",
            "fi",
        }, "\n")

        local layer, err = rex.session.new_layer({
            bounds = { 0.12, 0.14, 0.76, 0.62 },
            focus = true,
            layout = rex.layout.block({
                flavor = shell,
                label = "ghq",
                options = {
                    command = { "sh", "-c", pick },
                    cwd = os.getenv("HOME") or "/",
                },
            }),
        })
        if layer == nil then
            fail(tostring(err))
        end

        return {
            layer_id = layer.layer_id,
            block_id = layer.block_ids and layer.block_ids[1],
        }
    end,
})

rex.bind("cmd+o", "ghq_open")
