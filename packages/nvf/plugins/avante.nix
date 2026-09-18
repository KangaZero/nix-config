# ≈ lua/plugins/avante.lua
#
# No nvf module (vim.assistant covers chatgpt / copilot / neocodeium / supermaven-nvim
# only), so it comes in via vim.extraPlugins.
#
# The real config is macOS-only by design, returning early on any non-Darwin system.
# That guard is preserved, but it CANNOT stay a top-level `return`: nvf concatenates
# every extraPlugins setup into one init.lua, so a bare `return` at file scope
# truncates everything after this section (it silently killed the nekonight
# colorscheme and all LSP setup). The body is wrapped in an immediately-invoked
# function so `return` only exits the guard.
#
# The Ollama probe / model-pull logic and the :AvanteEnable command are otherwise
# kept intact.
{ pkgs, ... }:
{
  config.vim.extraPlugins.avante = {
    package = pkgs.vimPlugins.avante-nvim;
    after = [ "milli" ];
    setup = # lua
      ''
        (function()
        if vim.uv.os_uname().sysname ~= "Darwin" then
          return
        end

        -- A *base* (non-instruct) model, so it follows edit/chat prompts loosely.
        -- Because AI is on-demand (:AvanteEnable) its weight never hits startup.
        local MODEL = "maxwellb/Qwen3.5-35B-A3B-Base:latest"

        local function ollama_installed()
          return vim.fn.executable("ollama") == 1
        end

        -- Bounded, async-backed: vim.system():wait(ms) yields to the loop.
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

        -- Declared before ensure_ollama so the pull's on_exit closure can capture
        -- `opts` as an upvalue and re-apply it when the download completes.
        local opts = {
          provider = "ollama",
          auto_suggestions_provider = "ollama",
          providers = { ollama = { endpoint = "http://localhost:11434", model = MODEL } },
          behaviour = {
            auto_suggestions = false,
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
            return false
          end
          return true
        end

        -- Setup runs at load (cheap, no network) so :Avante* commands always exist.
        require("avante").setup(opts)

        -- The network/prompt/pull work lives OFF startup, behind a command.
        vim.api.nvim_create_user_command("AvanteEnable", function()
          if ensure_ollama() then
            opts.behaviour.auto_suggestions = true
            require("avante").setup(opts)
            vim.notify("[avante] AI enabled", vim.log.levels.INFO)
          end
        end, { desc = "Verify Ollama + enable Avante auto-suggestions" })
        end)()
      '';
  };
}
