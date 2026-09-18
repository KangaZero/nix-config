# ≈ lua/plugins/flash.lua
#
# setupOpts is freeform, so the real config's options port directly. The two Lua
# callbacks (search.exclude's focusable predicate and label.format) are passed as
# mkLuaInline. `search.exclude` is a mixed list of filetype strings and a function,
# so the whole list goes over as Lua rather than as a Nix list.
{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in
{
  config.vim.utility.motion.flash-nvim = {
    enable = true;
    setupOpts = {
      labels = "asdfghjklqwertyuiopzxcvbnm";

      search = {
        multi_window = true;
        forward = true;
        wrap = true;
        mode = "exact";
        incremental = false;
        exclude = mkLuaInline ''
          {
            "notify",
            "cmp_menu",
            "noice",
            "flash_prompt",
            function(win)
              return not vim.api.nvim_win_get_config(win).focusable
            end,
          }
        '';
        trigger = "";
        max_length = false;
      };

      jump = {
        jumplist = true;
        pos = "start";
        history = false;
        register = false;
        nohlsearch = false;
        autojump = true;
      };

      label = {
        uppercase = true;
        exclude = "";
        current = true;
        after = true;
        before = false;
        style = "overlay";
        reuse = "lowercase";
        distance = true;
        min_pattern_length = 0;
        rainbow = {
          enabled = true;
          shade = 3;
        };
        format = mkLuaInline ''
          function(opts)
            return { { opts.match.label, opts.hl_group } }
          end
        '';
      };

      highlight = {
        backdrop = false;
        matches = true;
        priority = 5000;
        groups = {
          match = "FlashMatch";
          current = "FlashCurrent";
          backdrop = "FlashBackdrop";
          label = "FlashLabel";
        };
      };

      pattern = "";
      continue = false;

      modes = {
        search = {
          enabled = false;
          highlight.backdrop = false;
          jump = {
            history = true;
            register = true;
            nohlsearch = true;
          };
        };
        char.enabled = false;
      };
    };
  };
}
