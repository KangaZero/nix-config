# ≈ lua/keymaps.lua
#
# vim.keymaps is a real nvf option (modules/neovim/init/mappings.nix); fields are
# key / mode / action / desc / lua / silent / expr / noremap.
#
# Telescope bindings are NOT here — nvf's telescope module owns its own mappings
# option, so they are set in plugins/telescope.nix instead to avoid two definitions
# of the same key.
#
# Deliberately not ported, because the backing code has no nvf equivalent:
#   <leader>zz / <leader>ts / <C-/>  -> lua/custom/{zen,safemode,terminal}.lua
#   <leader>c{k,P,c,s}               -> lua/util.lua case converters
#   <leader>uu                       -> nvim 0.12 builtin undotree packadd
#   <leader>gg                       -> util.create_popup_term_win lazygit float
#   <leader>p                        -> vim.pack.update (nvf has no vim.pack)
#   <leader>fc / <leader>fm          -> depend on util.lua and telescope internals
#   treesitter-textobjects a*/i*/]*/[* -> nvf's textobjects module ships its own
{
  config.vim.keymaps = [
    # Window navigation from terminal and insert mode
    {
      key = "<C-h>";
      mode = [
        "t"
        "i"
      ];
      action = "<C-\\><C-n><C-w>h";
      desc = "Go to Left Window";
    }
    {
      key = "<C-j>";
      mode = [ "t" ];
      action = "<C-\\><C-n><C-w>j";
      desc = "Go to Lower Window";
    }
    {
      key = "<C-k>";
      mode = [
        "t"
        "i"
      ];
      action = "<C-\\><C-n><C-w>k";
      desc = "Go to Upper Window";
    }
    {
      key = "<C-l>";
      mode = [
        "t"
        "i"
      ];
      action = "<C-\\><C-n><C-w>l";
      desc = "Go to Right Window";
    }

    # Keep the cursor centred on half/full page jumps
    {
      key = "<C-d>";
      mode = [
        "n"
        "v"
      ];
      action = "<C-d>zz";
      desc = "Half page down (centred)";
    }
    {
      key = "<C-u>";
      mode = [
        "n"
        "v"
      ];
      action = "<C-u>zz";
      desc = "Half page up (centred)";
    }
    {
      key = "<C-b>";
      mode = [
        "n"
        "v"
      ];
      action = "<C-b>zz";
      desc = "Page up (centred)";
    }
    {
      key = "<C-f>";
      mode = [
        "n"
        "v"
      ];
      action = "<C-f>zz";
      desc = "Page down (centred)";
    }

    # Window navigation
    {
      key = "<C-h>";
      mode = "n";
      action = "<C-w>h";
      desc = "Go to Left Window";
    }
    {
      key = "<C-j>";
      mode = "n";
      action = "<C-w>j";
      desc = "Go to Lower Window";
    }
    {
      key = "<C-k>";
      mode = "n";
      action = "<C-w>k";
      desc = "Go to Upper Window";
    }
    {
      key = "<C-l>";
      mode = "n";
      action = "<C-w>l";
      desc = "Go to Right Window";
    }

    # Window management
    {
      key = "<leader>ww";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>wincmd w<cr>";
      desc = "Go to Next Window";
    }
    {
      key = "<leader>wd";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>wincmd c<cr>";
      desc = "Close Current Window";
    }
    {
      key = "<leader>wx";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>wincmd x<cr>";
      desc = "Swap Windows";
    }
    {
      key = "<leader>wv";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>wincmd v<cr>";
      desc = "Split Window Vertically";
    }
    {
      key = "<leader>ws";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>wincmd s<cr>";
      desc = "Split Window Horizontally";
    }

    # Move visual selection
    {
      key = "J";
      mode = "v";
      action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv";
      desc = "Move line down";
    }
    {
      key = "K";
      mode = "v";
      action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv";
      desc = "Move line up";
    }

    # Execute Lua
    {
      key = "<leader>aa";
      mode = "n";
      action = ":.lua<CR>";
      desc = "Execute lua";
    }
    {
      key = "<leader>aa";
      mode = "v";
      action = ":lua<CR>";
      desc = "Execute lua";
    }

    # snacks pickers
    {
      key = "<leader><leader>";
      mode = [
        "n"
        "v"
      ];
      action = "function() require('snacks').picker.smart() end";
      lua = true;
      desc = "Smart Picker";
    }
    {
      key = "<leader>sk";
      mode = [
        "n"
        "v"
      ];
      action = "function() require('snacks').picker.keymaps() end";
      lua = true;
      desc = "Keymaps";
    }

    # grug-far
    {
      key = "<leader>sr";
      mode = [
        "n"
        "v"
      ];
      action = "function() require('grug-far').open() end";
      lua = true;
      desc = "Search and Replace";
    }

    # yazi
    {
      key = "<leader>E";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>Yazi cwd<cr>";
      desc = "Yazi at pwd";
    }
    {
      key = "<leader>e";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>Yazi<cr>";
      desc = "Yazi at current buffer";
    }
    {
      key = "<c-up>";
      mode = "n";
      action = "<cmd>Yazi toggle<cr>";
      desc = "Resume the last yazi session";
    }

    # flash
    {
      key = "s";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "function() require('flash').jump() end";
      lua = true;
      desc = "Flash";
    }
    {
      key = "S";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "function() require('flash').treesitter() end";
      lua = true;
      desc = "Flash Treesitter";
    }
    {
      key = "r";
      mode = "o";
      action = "function() require('flash').remote() end";
      lua = true;
      desc = "Remote Flash";
    }
    {
      key = "R";
      mode = [
        "o"
        "x"
      ];
      action = "function() require('flash').treesitter_search() end";
      lua = true;
      desc = "Treesitter Search";
    }

    # hlslens — keep search matches counted while jumping
    {
      key = "n";
      mode = "n";
      action = "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>";
      desc = "Next search match (hlslens)";
    }
    {
      key = "N";
      mode = "n";
      action = "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>";
      desc = "Prev search match (hlslens)";
    }
    {
      key = "*";
      mode = "n";
      action = "*<Cmd>lua require('hlslens').start()<CR>";
      desc = "Search word forward (hlslens)";
    }
    {
      key = "#";
      mode = "n";
      action = "#<Cmd>lua require('hlslens').start()<CR>";
      desc = "Search word backward (hlslens)";
    }
    {
      key = "g*";
      mode = "n";
      action = "g*<Cmd>lua require('hlslens').start()<CR>";
      desc = "Search partial forward (hlslens)";
    }
    {
      key = "g#";
      mode = "n";
      action = "g#<Cmd>lua require('hlslens').start()<CR>";
      desc = "Search partial backward (hlslens)";
    }
    {
      key = "<leader>l";
      mode = "n";
      action = "<Cmd>noh<CR>";
      desc = "Clear search highlight";
    }

    # opencode
    {
      key = "<leader>oa";
      mode = [
        "n"
        "x"
      ];
      action = "function() require('opencode').ask('@this: ') end";
      lua = true;
      desc = "Ask OpenCode…";
    }
    {
      key = "<leader>os";
      mode = [
        "n"
        "x"
      ];
      action = "function() require('opencode').select() end";
      lua = true;
      desc = "Select OpenCode…";
    }
    {
      key = "go";
      mode = [
        "n"
        "x"
      ];
      action = "function() return require('opencode').operator('@this ') end";
      lua = true;
      expr = true;
      desc = "Append range to OpenCode";
    }
    {
      key = "goo";
      mode = "n";
      action = "function() return require('opencode').operator('@this ') .. '_' end";
      lua = true;
      expr = true;
      desc = "Append line to OpenCode";
    }
    {
      key = "<S-C-u>";
      mode = "n";
      action = "function() require('opencode').command('session.half.page.up') end";
      lua = true;
      desc = "Scroll OpenCode up";
    }
    {
      key = "<S-C-d>";
      mode = "n";
      action = "function() require('opencode').command('session.half.page.down') end";
      lua = true;
      desc = "Scroll OpenCode down";
    }

    # Diagnostic navigation
    {
      key = "]e";
      mode = "n";
      action = "function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end";
      lua = true;
      desc = "Next Error";
    }
    {
      key = "[e";
      mode = "n";
      action = "function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end";
      lua = true;
      desc = "Prev Error";
    }
    {
      key = "]w";
      mode = "n";
      action = "function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end";
      lua = true;
      desc = "Next Warning";
    }
    {
      key = "[w";
      mode = "n";
      action = "function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end";
      lua = true;
      desc = "Prev Warning";
    }
    {
      key = "<leader>td";
      mode = [
        "n"
        "v"
      ];
      action = "function() vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines }) end";
      lua = true;
      desc = "Toggle inline diagnostics";
    }

    # Buffers
    {
      key = "<leader>bb";
      mode = "n";
      action = "<cmd>e #<cr>";
      desc = "Switch to Other Buffer";
    }

    # LSP
    {
      key = "<leader>fF";
      mode = [
        "n"
        "v"
      ];
      action = "function() vim.lsp.buf.format() end";
      lua = true;
      desc = "LSP Format";
    }

    # Terminal
    {
      key = "<Esc>";
      mode = "t";
      action = "<C-\\><C-n>";
      desc = "Enter normal mode in terminal";
    }
  ];
}
