# ≈ lua/plugins/tiny-inline-diagnostic.lua
#
# No nvf module, so it comes in via vim.extraPlugins. `setup` is a plain Lua string,
# which suits this config: the `severity` list holds vim.diagnostic.severity.*
# constants that a Nix attrset could not carry.
#
# after = ["hlslens"] only to give the extraPlugins DAG a deterministic order.
{ pkgs, ... }:
{
  config.vim.extraPlugins.tiny-inline-diagnostic = {
    package = pkgs.vimPlugins.tiny-inline-diagnostic-nvim;
    after = [ "hlslens" ];
    setup = ''
      require("tiny-inline-diagnostic").setup({
        preset = "modern",
        transparent_bg = true,
        hi = {
          error = "DiagnosticError",
          warn = "DiagnosticWarn",
          info = "DiagnosticInfo",
          hint = "DiagnosticHint",
          arrow = "NonText",
          background = "CursorLine",
          mixing_color = "Normal",
        },
        options = {
          show_source = {
            enabled = true,
            if_many = false,
          },
          show_code = true,
          show_related = {
            enabled = true,
            max_count = 3,
          },
          add_messages = {
            messages = true,
            display_count = true,
            use_max_severity = false,
            show_multiple_glyphs = true,
          },
          set_arrow_to_diag_color = false,
          use_icons_from_diagnostic = true,
          throttle = 20,
          softwrap = 30,
          multilines = {
            enabled = true,
            always_show = false,
            trim_whitespaces = true,
            tabstop = 4,
            severity = nil,
          },
          show_all_diags_on_cursorline = false,
          show_diags_only_under_cursor = false,
          enable_on_insert = false,
          enable_on_select = false,
          format = nil,
          overflow = {
            mode = "wrap",
          },
          break_line = {
            enabled = false,
            after = 30,
          },
          virt_texts = {
            priority = 2048,
          },
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
            vim.diagnostic.severity.HINT,
          },
          override_open_float = false,
          overwrite_events = nil,
          experimental = {
            use_window_local_extmarks = false,
          },
        },
        disabled_ft = {},
      })
    '';
  };
}
