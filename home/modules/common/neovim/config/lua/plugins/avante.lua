-- avante.nvim: local-LLM AI assist via Ollama. macOS-only by design
if vim.uv.os_uname().sysname ~= "Darwin" then
	return
end

-- NOTE: kept per user choice. This is a *base* (non-instruct) model, so it follows
-- edit/chat prompts loosely; because AI is on-demand (:AvanteEnable) its weight never
-- hits startup. Swap to an instruct tag (e.g. qwen2.5-coder:7b) if quality disappoints.
local MODEL = "maxwellb/Qwen3.5-35B-A3B-Base:latest"

local function ollama_installed()
	return vim.fn.executable("ollama") == 1
end

-- Bounded, async-backed: vim.system():wait(ms) yields to the loop, unlike vim.fn.system.
local function ollama_running()
	local res = vim.system(
		{ "curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", "http://localhost:11434/api/tags" },
		{ text = true }
	):wait(2000)
	return res.code == 0 and vim.trim(res.stdout or "") == "200"
end

local function model_available(model)
	local res = vim.system({ "ollama", "list" }, { text = true }):wait(5000)
	return res.code == 0 and (res.stdout or ""):find(model, 1, true) ~= nil
end

local function prompt_user(msg)
	return vim.fn.confirm(msg, "&Yes\n&No", 1) == 1
end

-- Avante config, declared before ensure_ollama so the pull's on_exit closure can
-- capture `opts` as an upvalue and re-apply it when the download completes. A `local`
-- is only in scope AFTER its declaration, so defining it below would make the closure
-- bind a nil global instead.
local opts = {
	provider = "ollama",
	auto_suggestions_provider = "ollama",
	providers = { ollama = { endpoint = "http://localhost:11434", model = MODEL } },
	behaviour = {
		auto_suggestions = false, -- flipped on by :AvanteEnable once Ollama is verified
		auto_set_keymaps = false,
		auto_apply_diff_after_generation = false,
	},
	suggestion = { debounce = 300, throttle = 300 },
}

local function ensure_ollama()
	if not ollama_installed() then
		vim.notify("[avante] ollama not on PATH — AI disabled", vim.log.levels.WARN)
		return false
	end
	if not ollama_running() then
		if not prompt_user("Ollama is not running. Start it now?") then
			return false
		end
		vim.system({ "ollama", "serve" }, { detach = true })
		-- Poll until the API answers, or give up after 10s (replaces `sleep 2`).
		if not vim.wait(10000, ollama_running, 200) then
			vim.notify("[avante] Ollama did not come up in time", vim.log.levels.ERROR)
			return false
		end
	end
	if not model_available(MODEL) then
		if not prompt_user("Model '" .. MODEL .. "' not found. Pull it now?") then
			return false
		end
		vim.notify("[avante] Pulling " .. MODEL .. " in background…", vim.log.levels.INFO)
		-- Detached pull. on_exit fires off the main loop, so every vim.* call is
		-- wrapped in vim.schedule. On success, auto-enable suggestions by re-applying
		-- opts (in scope below) so AI turns on the moment the download lands.
		vim.system({ "ollama", "pull", MODEL }, {}, function(res)
			vim.schedule(function()
				if res.code == 0 then
					opts.behaviour.auto_suggestions = true
					require("avante").setup(opts)
					vim.notify("[avante] " .. MODEL .. " ready — AI enabled", vim.log.levels.INFO)
				else
					vim.notify("[avante] Pull failed:\n" .. (res.stderr or "unknown error"), vim.log.levels.ERROR)
				end
			end)
		end)
		return false -- this launch stays disabled until the pull's on_exit flips it on
	end
	return true
end

vim.pack.add({
	{ src = "https://github.com/yetone/avante.nvim", build = "make" },
	"https://github.com/MunifTanjim/nui.nvim",
})

-- Setup runs at load (cheap, no network) so :Avante* commands always exist.
require("avante").setup(opts)

-- The network/prompt/pull work lives OFF startup, behind a command you run when you
-- actually want AI. Zero startup cost, no boot-time prompts, heavy model never
-- pre-loads.
vim.api.nvim_create_user_command("AvanteEnable", function()
	if ensure_ollama() then
		opts.behaviour.auto_suggestions = true
		require("avante").setup(opts)
		vim.notify("[avante] AI enabled", vim.log.levels.INFO)
	end
end, { desc = "Verify Ollama + enable Avante auto-suggestions" })
