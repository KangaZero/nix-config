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
require("mason-lspconfig").setup(not is_nixos and {
	ensure_installed = {
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
} or {})

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

--INFO: see for official config https://nix-community.github.io/nixd/md_nixd_2docs_2configuration.html
local nixd_host = vim.uv.os_gethostname()
local nixd_user = vim.uv.os_get_passwd().username
local nixd_opts

if is_nixos then
	-- NixOS (WSL or bare metal)
	local ref = string.format('(builtins.getFlake "%s")', vim.fn.expand("~/.config/multi-nix"))
	local options = {
		nixos = { expr = string.format("%s.nixosConfigurations.%s.options", ref, nixd_host) },
		home_manager = {
			expr = string.format("%s.nixosConfigurations.%s.options.home-manager.users.%s", ref, nixd_host, nixd_user),
		},
	}
	if vim.fn.has("wsl") == 1 then
		options.nixos_wsl = { expr = string.format("%s.nixosConfigurations.%s.options.wsl", ref, nixd_host) }
	end
	nixd_opts = {
		nixpkgs = { expr = string.format("import %s.inputs.nixpkgs { }", ref) },
		formatting = { command = { "nixfmt" } },
		options = options,
	}
elseif vim.fn.has("mac") == 1 then
	-- macOS: nix-darwin flake , home-manager embedded as darwin module
	local ref = string.format('(builtins.getFlake "%s")', vim.fn.expand("~/.config/multi-nix"))
	nixd_opts = {
		nixpkgs = { expr = string.format("import %s.inputs.nixpkgs { }", ref) },
		formatting = { command = { "nixfmt" } },
		options = {
			nixos = { expr = string.format("%s.darwinConfigurations.%s.options", ref, nixd_host) },
			home_manager = {
				expr = string.format(
					"%s.darwinConfigurations.%s.options.home-manager.users.%s",
					ref,
					nixd_host,
					nixd_user
				),
			},
		},
	}
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
