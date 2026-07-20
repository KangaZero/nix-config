if vim.uv.os_uname().sysname ~= "Darwin" then
	return
end

local MODEL = "maxwellb/Qwen3.5-35B-A3B-Base:latest"

---@return boolean
local function ollama_installed()
	return vim.fn.executable("ollama") == 1
end

---@return boolean
local function ollama_running()
	local ok, code = pcall(function()
		return vim.fn.system({
			"curl",
			"-s",
			"-o",
			"/dev/null",
			"-w",
			"%{http_code}",
			"http://localhost:11434/api/tags",
		})
	end)
	return ok and code == "200"
end

---@param model string
---@return boolean
local function model_available(model)
	local result = vim.fn.system({ "ollama", "list" })
	return result:find(model, 1, true) ~= nil
end

---@return boolean
local function prompt_user(msg)
	return vim.fn.confirm(msg, "&Yes\n&No", 1) == 1
end

---@return boolean
local function ensure_ollama()
	if not ollama_installed() then
		vim.notify("[avante] ollama not found on PATH — AI completion disabled", vim.log.levels.WARN)
		return false
	end

	if not ollama_running() then
		if not prompt_user("Ollama is not running. Start it now?") then
			vim.notify("[avante] Skipped — AI completion disabled for this session", vim.log.levels.INFO)
			return false
		end
		vim.fn.jobstart({ "ollama", "serve" }, { detach = true })
		vim.fn.system({ "sleep", "2" })
		if not ollama_running() then
			vim.notify("[avante] Failed to start Ollama — AI completion disabled", vim.log.levels.ERROR)
			return false
		end
		vim.notify("[avante] Ollama started", vim.log.levels.INFO)
	end

	if not model_available(MODEL) then
		if not prompt_user("Model '" .. MODEL .. "' not found. Pull it now? (may take a while)") then
			vim.notify("[avante] Model missing — AI completion disabled for this session", vim.log.levels.INFO)
			return false
		end
		vim.notify("[avante] Pulling " .. MODEL .. "...", vim.log.levels.INFO)
		vim.fn.system({ "ollama", "pull", MODEL })
	end

	return true
end

local ai_ready = ensure_ollama()

vim.pack.add({
	{
		src = "https://github.com/yetone/avante.nvim",
		build = "make",
	},
	"https://github.com/MunifTanjim/nui.nvim",
})

require("avante").setup({
	provider = "ollama",
	auto_suggestions_provider = "ollama",
	providers = {
		ollama = {
			endpoint = "http://localhost:11434",
			model = MODEL,
		},
	},
	behaviour = {
		auto_suggestions = ai_ready,
		auto_set_keymaps = false,
		auto_apply_diff_after_generation = false,
	},
	suggestion = {
		debounce = 300,
		throttle = 300,
	},
})
