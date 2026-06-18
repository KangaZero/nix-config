-- Fast, offline syntax check for every Lua file in this config.
-- Run with:  nvim --clean -l scripts/check-syntax.lua
-- loadfile() compiles a chunk WITHOUT executing it, so this catches parse
-- errors (e.g. code after `return`, unbalanced braces) without cloning or
-- loading any plugins. --clean skips user config so it stays hermetic.

local script = debug.getinfo(1, "S").source:sub(2)
local root = vim.fn.fnamemodify(script, ":p:h:h") -- scripts/ -> config root

-- Gather every .lua file under the config root (init.lua + nested).
local seen, files = {}, {}
for _, pat in ipairs({ root .. "/*.lua", root .. "/**/*.lua" }) do
	for _, f in ipairs(vim.fn.glob(pat, false, true)) do
		if not seen[f] then
			seen[f] = true
			files[#files + 1] = f
		end
	end
end
table.sort(files)

local failed = 0
for _, f in ipairs(files) do
	local chunk, err = loadfile(f)
	if not chunk then
		failed = failed + 1
		io.stderr:write("SYNTAX ERROR: " .. f .. "\n  " .. tostring(err) .. "\n")
	end
end

if failed > 0 then
	io.stderr:write(("\n%d/%d file(s) failed syntax check\n"):format(failed, #files))
	os.exit(1)
end

io.stdout:write(("syntax OK: %d lua files\n"):format(#files))
