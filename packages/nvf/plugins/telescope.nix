# ≈ lua/plugins/telescope.lua
#
# nvf's telescope module owns a `mappings` option, so the real config's Telescope
# keybindings are set here rather than in ../keymaps.nix — two definitions of the
# same key would conflict.
#
# telescope-fzf-native is declared as an extension; nvf builds libfzf.so via Nix,
# which is the same reason the real config pulls it from pkgs.vimPlugins instead of
# letting vim.pack compile it at runtime.
{ pkgs, ... }:
{
  config.vim.telescope = {
    enable = true;

    mappings = {
      findFiles = "<leader>ff";
      liveGrep = "<leader>fg";
      buffers = "<leader>fb";
      gitStatus = "<leader>fG";
      lspDefinitions = "<leader>gd";
      lspReferences = "<leader>gr";
      lspImplementations = "<leader>gI";
      diagnostics = "<leader>xx";
    };

    extensions = [
      {
        name = "fzf";
        packages = [ pkgs.vimPlugins.telescope-fzf-native-nvim ];
        setup.fzf = {
          fuzzy = true;
          override_generic_sorter = true;
          override_file_sorter = true;
          case_mode = "smart_case";
        };
      }
    ];

    setupOpts = {
      defaults = {
        layout_strategy = "horizontal";
        layout_config = {
          horizontal.preview_width = 0.75;
          width = 0.87;
          height = 0.80;
        };
        path_display = [ "truncate" ];
        file_ignore_patterns = [
          "node_modules"
          "%.git/"
        ];
      };

      pickers = {
        find_files = {
          theme = "dropdown";
          hidden = true;
          find_command = [
            "fd"
            "--type"
            "f"
            "--strip-cwd-prefix"
            "--hidden"
            "--follow"
            "--exclude"
            ".git"
          ];
        };
        live_grep.theme = "dropdown";
        buffers = {
          theme = "dropdown";
          sort_mru = true;
          ignore_current_buffer = true;
        };
        git_status.theme = "dropdown";
        git_branches.theme = "dropdown";
        lsp_definitions = {
          theme = "dropdown";
          jump_type = "never";
        };
        lsp_references = {
          theme = "dropdown";
          show_line = false;
        };
        lsp_implementations.theme = "dropdown";
        diagnostics.theme = "cursor";
      };
    };
  };
}
