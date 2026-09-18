# ≈ lua/options.lua
#
# `vim.options` is a freeform submodule (modules/wrapper/rc/options.nix), so every
# `vim.o.*` assignment in the real config ports declaratively. Where nvf ships a
# curated wrapper for a setting (lineNumberMode, searchCase, preventJunkFiles,
# undoFile) the wrapper is used instead of the raw option, since those also drive
# related behaviour inside nvf's own modules.
{ lib, ... }:
{
  config.vim = {
    # Curated equivalents: lineNumberMode covers number + relativenumber,
    # searchCase covers ignorecase + smartcase.
    lineNumberMode = "relNumber";
    searchCase = "smart";
    preventJunkFiles = true;
    undoFile.enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";

      # yazi owns file management; netrw stays off.
      loaded_netrwPlugin = 1;
      netrw_banner = 0;
    };

    options = {
      mouse = "";
      # nvf declares this as `tm` (default 500); setting `timeoutlen` instead would
      # emit a second key and nvf's declared one would win.
      tm = 300;
      updatetime = 250;
      cursorline = true;
      wrap = true;
      confirm = true;
      termguicolors = true;
      clipboard = "unnamedplus";
      signcolumn = "yes";
      list = false;
      inccommand = "split";
      smoothscroll = true;

      # Required for opencode.nvim's `events.reload`.
      autoread = true;

      foldmethod = "expr";
      foldexpr = "v:lua.vim.treesitter.foldexpr()";
      foldlevel = 99;
      foldlevelstart = 99;
    };

    diagnostics = {
      enable = true;
      config = {
        virtual_text = true;
        # Keys are vim.diagnostic.severity.* constants, not strings, so the whole
        # table has to arrive as Lua rather than as a converted Nix attrset.
        signs =
          lib.generators.mkLuaInline # lua
            ''
              {
                text = {
                  [vim.diagnostic.severity.ERROR] = " ",
                  [vim.diagnostic.severity.WARN]  = " ",
                  [vim.diagnostic.severity.INFO]  = " ",
                  [vim.diagnostic.severity.HINT]  = " ",
                },
              }
            '';
      };
    };

    # No nvf option for the LSP log level.
    luaConfigRC.lsp-log-level = # lua
      ''
        -- "debug" writes huge volumes to the LSP log (disk + slowdown).
        vim.lsp.log.set_level("warn")
      '';
  };
}
