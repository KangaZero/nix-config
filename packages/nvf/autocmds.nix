# ≈ lua/autocmds.lua
#
# vim.augroups / vim.autocmds are real nvf options (modules/neovim/init/autocmds.nix),
# so these stay declarative. `callback` takes a luaInline, which is how a Nix attrset
# carries a Lua function.
{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in
{
  config.vim = {
    augroups = [
      { name = "nvf_user"; }
      { name = "nvf_close_with_q"; }
    ];

    autocmds = [
      {
        event = [ "TextYankPost" ];
        group = "nvf_user";
        desc = "highlight when yanking text";
        callback = mkLuaInline "function() vim.hl.on_yank() end";
      }

      {
        event = [ "BufWinEnter" ];
        group = "nvf_user";
        pattern = [ "*" ];
        desc = "open help pages as a vertical split on the far right";
        callback =
          # lua
          mkLuaInline ''
            function()
              if vim.bo.filetype == "help" then
                vim.cmd("wincmd L")
              end
            end
          '';
      }

      {
        event = [ "VimEnter" ];
        group = "nvf_user";
        desc = "Truncate the LSP log when it grows past 50 MB (nvim never rotates it)";
        callback =
          # lua
          mkLuaInline ''
            function()
              local path = vim.lsp.log.get_filename()
              local st = vim.uv.fs_stat(path)
              if st and st.size > 50 * 1024 * 1024 then
                vim.uv.fs_open(path, "w", 420, function(_, fd)
                  if fd then vim.uv.fs_close(fd) end
                end)
              end
            end
          '';
      }

      {
        event = [ "FileType" ];
        group = "nvf_close_with_q";
        pattern = [
          "PlenaryTestPopup"
          "checkhealth"
          "dap-float"
          "dbout"
          "gitsigns-blame"
          "grug-far"
          "help"
          "terminal"
          "lazygit"
          "TelescopePrompt"
          "nvim-undotree"
          "neotest-output"
          "neotest-output-panel"
          "neotest-summary"
          "notify"
          "qf"
          "spectre_panel"
          "startuptime"
          "tsplayground"
        ];
        desc = "close scratch-ish filetypes with q";
        callback =
          # lua
          mkLuaInline ''
            function(event)
              vim.bo[event.buf].buflisted = false
              vim.schedule(function()
                if vim.bo.filetype == "TelescopePrompt" then
                  vim.bo.complete = ""
                end
                vim.keymap.set("n", "q", function()
                  vim.cmd("close")
                  pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
                end, { buffer = event.buf, silent = true, desc = "Quit buffer" })
              end)
            end
          '';
      }

      {
        event = [ "BufWritePre" ];
        group = "nvf_user";
        pattern = [ "*" ];
        desc = "format on write via conform";
        callback =
          # lua
          mkLuaInline ''
            function(args)
              require("conform").format({ bufnr = args.buf })
            end
          '';
      }

      {
        event = [ "BufLeave" ];
        group = "nvf_user";
        nested = true;
        desc = "autosave modified buffers, and re-source this config's own Lua";
        callback =
          # lua
          mkLuaInline ''
            function()
              if vim.bo.modified and vim.bo.buftype == "" then
                vim.cmd("silent! w")
                vim.lsp.buf.format()
              end
              local file = vim.fn.expand("%:p")
              if file:match("^" .. vim.fn.stdpath("config") .. "/.*%.lua$") then
                vim.cmd("source %")
              end
            end
          '';
      }
    ];
  };
}
