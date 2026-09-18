# ≈ lua/plugins/conform.lua
#
# format_on_save is set to null: the real config formats from a BufWritePre autocmd
# (see ../autocmds.nix), and leaving nvf's default function in place would format
# twice per write.
{
  config.vim.formatter.conform-nvim = {
    enable = true;
    setupOpts = {
      format_on_save = null;
      formatters_by_ft = {
        lua = [ "stylua" ];
        python = {
          __unkeyed-1 = "ruff";
          lsp_format = "fallback";
        };
        rust = {
          __unkeyed-1 = "rustfmt";
          lsp_format = "fallback";
        };
        javascript = {
          __unkeyed-1 = "biome";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        typescript = {
          __unkeyed-1 = "biome";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        json = {
          __unkeyed-1 = "biome";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        nix = [ "nixfmt" ];
      };
    };
  };
}
