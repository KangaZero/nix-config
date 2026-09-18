# ≈ lua/plugins/completion.lua
#
# setupOpts is freeform (lib/types/plugins.nix: freeformType = anything), so the
# structural half of the real blink config ports directly. The `draw` block is
# handed over as mkLuaInline instead: its `columns` entries are mixed
# array/hash Lua tables and its `text`/`highlight` fields are closures, neither of
# which survives a plain Nix -> Lua attrset conversion cleanly.
#
# Not ported: the ~50 BlinkCmp* highlight groups and the ColorScheme autocmd that
# reapplies them. Those exist to make blink match nekonight's deep-ocean palette by
# hand; nvf's theme handling covers the same ground for the themes it manages, and
# reproducing them here would be ~60 lines of embedded Lua for no declarative gain.
{ lib, ... }:
{
  config.vim.autocomplete.blink-cmp = {
    enable = true;
    setupOpts = {
      keymap = {
        preset = "super-tab";
        # 'accept' handles ghost text when the menu is closed; 'select_and_accept'
        # handles the highlighted item when it is open. Both are needed.
        "<Tab>" = [
          "accept"
          "snippet_forward"
          "fallback"
        ];
        "<C-Y>" = [ "select_and_accept" ];
      };

      appearance = {
        nerd_font_variant = "mono";
        use_nvim_cmp_as_default = false;
      };

      completion = {
        accept.auto_brackets.enabled = true;

        menu = {
          border = "rounded";
          winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None";
          scrollbar = true;
          draw = lib.generators.mkLuaInline ''
            {
              align_to = "label",
              padding = { 0, 1 },
              gap = 1,
              treesitter = { "lsp" },
              columns = {
                { "kind_icon" },
                { "label", "label_description", gap = 1 },
                { "source_name" },
              },
              components = {
                kind_icon = {
                  ellipsis = false,
                  text = function(ctx)
                    if ctx.source_name == "Snippets" then
                      return "󱄽 "
                    end
                    return ctx.kind_icon .. ctx.icon_gap
                  end,
                  highlight = function(ctx)
                    return { { group = ctx.kind_hl, priority = 20000 } }
                  end,
                },
                label = {
                  width = { fill = true, max = 60 },
                  text = function(ctx)
                    return ctx.label .. (ctx.label_detail or "")
                  end,
                  highlight = function(ctx)
                    local label = ctx.label
                    local highlights = {
                      {
                        0,
                        #label,
                        group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
                      },
                    }
                    if ctx.label_detail then
                      table.insert(highlights, {
                        #label,
                        #label + #ctx.label_detail,
                        group = "BlinkCmpLabelDetail",
                      })
                    end
                    return highlights
                  end,
                },
                source_name = {
                  width = { max = 6 },
                  text = function(ctx)
                    local labels = {
                      LSP = "lsp",
                      Path = "path",
                      Snippets = "snip",
                      Buffer = "buf",
                    }
                    return labels[ctx.source_name] or ctx.source_name:lower():sub(1, 4)
                  end,
                  highlight = function(_)
                    return "BlinkCmpLabelDescription"
                  end,
                },
              },
            }
          '';
        };

        documentation = {
          auto_show = true;
          auto_show_delay_ms = 0;
          treesitter_highlighting = true;
          window = {
            border = "rounded";
            winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc";
            scrollbar = true;
          };
        };

        ghost_text.enabled = true;
      };

      sources = {
        default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
        providers = {
          lsp.score_offset = 100;
          path.score_offset = 97;
          buffer.score_offset = 95;
          # Snippets ranked last — useful but rarely what you want first.
          snippets.score_offset = -100;
        };
        per_filetype.opencode_ask = [
          "lsp"
          "buffer"
        ];
      };

      fuzzy.implementation = "prefer_rust_with_warning";
    };
  };
}
