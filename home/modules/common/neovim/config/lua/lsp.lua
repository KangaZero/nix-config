-- INFO: On NixOS, LSP servers/formatters are managed by Nix (neovim.nix home.packages).
-- Mason is kept for its UI but skips ensure_installed — binaries come from PATH.
-- On other systems, Mason installs everything as normal.
local is_nixos = vim.uv.fs_stat("/etc/NIXOS") ~= nil

require("mason").setup()

-- NOTE: mason-lspconfig `ensure_installed` accepts LSP server names ONLY.
-- `stylua` is a formatter, not a server -> it was rejected here. Moved to the
-- mason-registry block below. With mason-lspconfig v2, `automatic_enable`
-- defaults to true, so every installed server is auto-enabled via
-- `vim.lsp.enable()`; explicit enables below are redundant but harmless.
require("mason-lspconfig").setup({
	-- On NixOS every binary is on PATH from Nix, so Mason installs nothing.
	-- Off NixOS, Mason installs this set. The native TS 7 server is not here: it
	-- ships as `tsc` in the `typescript` package, which Mason does not carry, so
	-- off NixOS the TS server is always vtsls.
	ensure_installed = is_nixos and {} or {
		"lua_ls",
		"bashls",
		"pyright",
		"ruff",
		"clangd",
		"vtsls",
		"cssls",
		"jsonls",
		"biome",
		"eslint",
		"tailwindcss",
		"rust_analyzer",
		"html",
	},
	-- vtsls is enabled by hand below, so stop automatic_enable from attaching it
	-- and duplicating diagnostics. `tsc` needs no exclusion: Mason cannot install
	-- it, so automatic_enable never sees it.
	automatic_enable = { exclude = { "vtsls" } },
})

-- Non-LSP tools (formatters/linters) that mason-lspconfig can't install.
-- conform.nvim needs stylua on PATH; mason adds its bin dir to PATH.
if not is_nixos then
	local ensure_tools = { "stylua" }
	local ok_registry, registry = pcall(require, "mason-registry")
	if ok_registry then
		registry.refresh(function()
			for _, name in ipairs(ensure_tools) do
				local ok_pkg, pkg = pcall(registry.get_package, name)
				if ok_pkg and not pkg:is_installed() then
					pkg:install()
				end
			end
		end)
	end
end
-- lsp configs
-- vim.lsp.config("lua_ls", {
-- 	settings = {
-- 		Lua = {
-- 			diagnostics = { globals = { "vim", "require" } },
-- 			workspace = {
-- 				checkThirdParty = true,
-- 				library = vim.api.nvim_get_runtime_file("", true)
-- 			},
-- 			telemetry = { enable = false },
-- 		},
-- 	},
-- })
vim.lsp.config("lua_ls", {
	on_init = function(client)
		client.server_capabilities.documentFormattingProvider = false
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end
		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				version = "LuaJIT",
				path = { "lua/?.lua", "lua/?/init.lua" },
			},
			workspace = {
				checkThirdParty = false,
				library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
					"${3rd}/luv/library",
					"${3rd}/busted/library",
				}),
			},
		})
	end,
	settings = {
		Lua = {
			format = { enable = false },
			diagnostics = { globals = { "vim", "require" } },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("bashls", {
	filetypes = { "sh", "bash", "zsh" },
})
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				enable = true,
			},
		},
	},
})

-- TypeScript/JavaScript: vtsls. Inlay hints + auto-complete function calls.
-- Formatting handed to conform (biome/prettier), so disable the server's.
vim.lsp.config("vtsls", {
	settings = {
		typescript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			inlayHints = {
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
			},
		},
		javascript = {
			inlayHints = {
				parameterNames = { enabled = "literals" },
				variableTypes = { enabled = true },
			},
		},
	},
	on_init = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
})

-- TypeScript/JavaScript: `tsc` is the PRIMARY server; vtsls above is the fallback
-- (see the enable logic at the bottom — only one attaches per buffer). Formatting
-- handed to conform (biome/prettier), so disable the server's.
--
-- TypeScript 7 is the native Go port and serves LSP over `--lsp --stdio`; plain
-- `--stdio` is rejected without `--lsp`. nvim-lspconfig ships no `lsp/tsc.lua` (only
-- the pre-rename `tsgo`), so this is defined in full rather than layered on a
-- shipped default — including the inlay hints that default used to supply.
vim.lsp.config("tsc", {
	cmd = function(dispatchers, config)
		local bin = "tsc"
		local root = (config or {}).root_dir
		if root then
			local local_bin = vim.fs.joinpath(root, "node_modules/.bin", bin)
			if vim.fn.executable(local_bin) == 1 then
				bin = local_bin
			end
		end
		return vim.lsp.rpc.start({ bin, "--lsp", "--stdio" }, dispatchers)
	end,
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	-- One instance serves a whole monorepo, so root at the package manager lockfile
	-- and fall back to a tsconfig only when there is no lockfile. Nested tables are
	-- priority groups: every marker in a group ranks equally.
	root_markers = {
		{ "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lock", "bun.lockb" },
		{ "tsconfig.json", "jsconfig.json" },
		{ ".git" },
	},
	settings = {
		typescript = {
			inlayHints = {
				parameterNames = { enabled = "literals", suppressWhenArgumentMatchesName = true },
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				enumMemberValues = { enabled = true },
			},
		},
	},
	on_init = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
})

-- Python: pyright for types, ruff for lint/format. Disable ruff hover so
-- pyright owns hover; let pyright do type-checking only (ruff handles imports).
vim.lsp.config("pyright", {
	settings = {
		pyright = { disableOrganizeImports = true }, -- ruff organizes imports
		python = {
			analysis = {
				typeCheckingMode = "standard",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
})

vim.lsp.config("ruff", {
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
})

-- ESLint: format-on-command via the server's organizeImports/fixAll if wanted.
vim.lsp.config("eslint", {
	settings = {
		workingDirectories = { mode = "auto" },
	},
})

--INFO: official config schema
-- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
--
-- Flake attr names track networking.hostName (hosts/*/default.nix + the nixos-wsl
-- default), so the live hostname is the config key. Strip any DNS/mDNS suffix
-- (macOS can hand back "host.local") before using it as an attr path.
local nixd_host = vim.uv.os_gethostname():gsub("%..*$", "")
local nixd_ref = string.format('(builtins.getFlake "%s")', vim.fn.expand("~/.config/multi-nix"))

-- home-manager is used as a NixOS / nix-darwin *module* here, not standalone — that's
-- case "B" in nixd's docs. The per-user option tree therefore sits behind the `users`
-- submodule type: `options.home-manager.users.<username>` does NOT exist (that node only
-- carries _type/type/value/declarations/...), so it evaluated to
-- `error: attribute '<username>' missing` and nixd silently served zero HM completions.
-- `.users.type.getSubOptions []` unwraps the submodule into real option declarations.
local function nixd_hm_expr(flake_attr)
	return string.format("%s.%s.%s.options.home-manager.users.type.getSubOptions []", nixd_ref, flake_attr, nixd_host)
end

-- `options` keys are arbitrary labels (nixd merges every entry for completion), but each
-- entry is one lazy full-config eval — nixpkgs alone is 200~300MB of names per nixd's
-- docs — so keep the map minimal: the dropped `nixos_wsl` entry pointed at `options.wsl`,
-- which the `nixos` entry's option tree already contains.
local function nixd_settings(label, flake_attr)
	return {
		nixpkgs = { expr = string.format("import %s.inputs.nixpkgs { }", nixd_ref) },
		formatting = { command = { "nixfmt" } },
		options = {
			[label] = { expr = string.format("%s.%s.%s.options", nixd_ref, flake_attr, nixd_host) },
			["home-manager"] = { expr = nixd_hm_expr(flake_attr) },
		},
	}
end

local nixd_opts
if is_nixos then
	-- NixOS (WSL or bare metal)
	nixd_opts = nixd_settings("nixos", "nixosConfigurations")
elseif vim.fn.has("mac") == 1 then
	-- macOS: nix-darwin flake, home-manager embedded as a darwin module
	nixd_opts = nixd_settings("darwin", "darwinConfigurations")
end

vim.lsp.config("nixd", {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
	settings = { nixd = nixd_opts },
})

vim.lsp.enable("nixd")
vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("sourcekit")

-- TS/JS server priority: prefer the native TS 7 server, fall back to vtsls.
-- Exactly one attaches, so no duplicate diagnostics, hover, or completion.
-- Gated on is_nixos because `tsc` on PATH only guarantees `--lsp` support when it
-- comes from Nix (pinned TS >= 7) — a stale global TS <= 6 `tsc` passes an
-- executable() check and then fails the LSP handshake.
if is_nixos and vim.fn.executable("tsc") == 1 then
	vim.lsp.enable("tsc")
else
	vim.lsp.enable("vtsls")
end
