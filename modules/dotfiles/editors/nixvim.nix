# Pure-nixvim editor module. Mirrors the AstroNvim feature set AND its
# default keymap tables (issue #1). Layout: feature parity is achieved
# via nixvim's plugin modules; muscle-memory parity via the keymap list
# at the bottom of this file. Heirline statusline/tabline/dashboard are
# intentionally still divergent — see issue #1 for visual-parity scope.
{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.dotfiles.editors.nixvim;

  # Keymap constructors — collapse the 5-line nixvim attrset down to one
  # line so the long mapping table below stays scannable.
  nmap = key: action: desc:
    { mode = "n"; inherit key action; options.desc = desc; };
  vmap = key: action: desc:
    { mode = "v"; inherit key action; options.desc = desc; };
  tmap = key: action: desc:
    { mode = "t"; inherit key action; options.desc = desc; };
in
{
  config = mkIf cfg.enable {
    programs.nixvim = {
        enable = true;
        # Pin nixvim's nixpkgs to the one home-manager already uses (pkgs.path).
        # nixvim's flake pins a different nixpkgs rev than our
        # `inputs.nixvim.inputs.nixpkgs.follows`, so the default `nixpkgs.source`
        # emits an eval-time warning about the divergence on every nixpkgs bump.
        # Setting it explicitly silences that permanently with no build change —
        # it's the same nixpkgs nixvim was already resolving to via the follows.
        nixpkgs.source = pkgs.path;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        globals = {
          mapleader = " ";
          maplocalleader = ",";
        };

        opts = {
          number = true;
          relativenumber = false;
          spell = false;
          signcolumn = "yes";
          wrap = true;
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
          smartindent = true;
          ignorecase = true;
          smartcase = true;
          termguicolors = true;
          undofile = true;
          updatetime = 300;
          timeoutlen = 500;
          splitbelow = true;
          splitright = true;
          scrolloff = 8;
          sidescrolloff = 8;
        };

        colorschemes.catppuccin = {
          enable = true;
          settings.flavour = "mocha";
        };

        plugins = {
          neo-tree = {
            enable = true;
            settings = {
              # The three sources show up as tabs along the top of the
              # neo-tree sidebar when source_selector.winbar is on.
              sources = [ "filesystem" "buffers" "git_status" ];
              source_selector = {
                winbar = true;
                statusline = false;
                content_layout = "center";
                sources = [
                  { source = "filesystem";  display_name = " 󰉓 Files "; }
                  { source = "buffers";     display_name = " 󰈚 Bufs "; }
                  { source = "git_status";  display_name = " 󰊢 Git "; }
                ];
              };
              filesystem.filtered_items = {
                hide_dotfiles = false;
                hide_gitignored = false;
                never_show = [
                  ".DS_Store"
                  "thumbs.db"
                  ".DocumentRevisions-V100"
                  ".fseventsd"
                  ".Spotlight-V100"
                  ".TemporaryItems"
                  ".Trashes"
                  ".VolumeIcon.icns"
                  ".com.apple.timemachine.donotpresent"
                ];
              };
            };
          };

          telescope = {
            enable = true;
            extensions.fzf-native.enable = true;
          };

          treesitter = {
            enable = true;
            settings = {
              highlight.enable = true;
              indent.enable = true;
            };
          };

          # Treesitter-powered text objects. Adds `af`/`if`/`ac`/`ic`/`aa`/`ia`
          # for function/class/argument, and `]f`/`[f` etc. to jump between
          # them. Nixvim merges this into plugins.treesitter.settings.textobjects.
          treesitter-textobjects = {
            enable = true;
            settings = {
              select = {
                enable = true;
                lookahead = true;
                keymaps = {
                  "af" = "@function.outer";
                  "if" = "@function.inner";
                  "ac" = "@class.outer";
                  "ic" = "@class.inner";
                  "aa" = "@parameter.outer";
                  "ia" = "@parameter.inner";
                };
              };
              move = {
                enable = true;
                set_jumps = true;
                goto_next_start = {
                  "]f" = "@function.outer";
                  "]c" = "@class.outer";
                };
                goto_previous_start = {
                  "[f" = "@function.outer";
                  "[c" = "@class.outer";
                };
              };
            };
          };

          # Auto close/rename HTML/JSX/Vue tags. Triggered by `>` and rename.
          ts-autotag.enable = true;

          # Auto-detect indent style per file (tabs vs 2 vs 4 spaces).
          # Overrides the global shiftwidth=2 when a file disagrees.
          guess-indent.enable = true;

          tmux-navigator.enable = true;
          web-devicons.enable = true;
          which-key.enable = true;
          gitsigns.enable = true;
          nvim-autopairs.enable = true;
          comment.enable = true;
          indent-blankline.enable = true;

          # AstroNvim parity additions ───────────────────────────────
          # Notifications (replaces :messages with toast popups).
          notify.enable = true;
          # TODO/FIXME/HACK comment highlighting + telescope picker.
          todo-comments.enable = true;
          # Highlight other occurrences of word under cursor.
          illuminate.enable = true;
          # Breadcrumbs: shows symbol path (class > fn > block) in winbar.
          navic = {
            enable = true;
            settings.lsp.auto_attach = true;
          };
          # Aerial: side-panel symbol outline. Navic shows *where* you are
          # in the winbar; aerial shows the *whole map* in a togglable
          # split. Bound to `<Leader>lS` below.
          aerial = {
            enable = true;
            settings = {
              backends = [ "lsp" "treesitter" "markdown" ];
              layout = { default_direction = "prefer_right"; min_width = 25; };
              attach_mode = "global";
              close_automatic_events = [ "unfocus" ];
              filter_kind = false;
            };
          };
          # Buffer tabs across the top, with close buttons and offsets
          # that avoid clashing with neo-tree.
          bufferline = {
            enable = true;
            settings.options.offsets = [
              { filetype = "neo-tree"; text = "File Explorer"; separator = true; }
            ];
          };

          # Optional: Claude Code embedded in an nvim split. Toggle via
          # `<Leader>ac`. The `claude` CLI is expected to be on the
          # shell's PATH (Homebrew, npm install -g, etc.) rather than
          # bundled by nixvim — the nixpkgs claude-code is unfree and
          # gets refused during wrapper construction even when the
          # system pkgs allows unfree elsewhere.
          claude-code = mkIf cfg.claudeCode.enable {
            enable = true;
            settings.window = {
              position = "vertical";
              split_ratio = 0.35;
            };
          };

          lualine = {
            enable = true;
            settings = {
              # Don't let lualine paint over neo-tree's source-selector
              # winbar (Files / Bufs / Git tabs).
              options.disabled_filetypes.winbar = [ "neo-tree" ];
              # Wire navic into the winbar so the breadcrumbs render at the
              # top of each code window. `cond` keeps the winbar off when
              # navic has nothing to say (no LSP attached / non-code buffer).
              winbar = {
                lualine_c = [
                  {
                    __unkeyed-1.__raw = ''function() return require("nvim-navic").get_location() end'';
                    cond.__raw = ''function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end'';
                  }
                ];
              };
            };
          };

          # AstroNvim ships `jk` / `kj` insert-mode escape via better-escape.
          better-escape.enable = true;

          # Terminal toggling — backing for `<C-/>` and the `<Leader>t*`
          # terminal group.
          toggleterm = {
            enable = true;
            settings = {
              open_mapping = "[[<c-\\>]]";
              direction = "float";
              shade_terminals = true;
            };
          };

          # Session save/load — substitutes for AstroNvim's resession.
          # Keymaps under `<Leader>S*` below wire to its lua API.
          persistence = {
            enable = true;
            settings.options = [ "buffers" "curdir" "tabpages" "winsize" "help" "globals" "skiprtp" ];
          };

          # Completion: blink.cmp (AstroNvim's current default, replacing
          # nvim-cmp). The `enter` preset keeps <CR> as accept and frees
          # <Tab>/<S-Tab> for luasnip snippet navigation — closest match
          # to the previous nvim-cmp behavior here.
          blink-cmp = {
            enable = true;
            settings = {
              keymap.preset = "enter";
              snippets.preset = "luasnip";
              sources.default = [ "lsp" "path" "snippets" "buffer" ];
              completion = {
                accept.auto_brackets.enabled = true;
                documentation.auto_show = true;
                ghost_text.enabled = true;
              };
              signature.enabled = true;
              # Buffer-local kill switch wired to <Leader>uc below.
              enabled.__raw = ''
                function() return not vim.b.completion_disabled end
              '';
            };
          };
          luasnip.enable = true;
          # Pre-baked snippet collection feeding luasnip (and via the
          # snippets source, blink.cmp's menu).
          friendly-snippets.enable = true;

          lsp = {
            enable = true;
            servers = {
              nil_ls.enable = true;
              lua_ls.enable = true;
              ts_ls.enable = true;
              pyright.enable = true;
              rust_analyzer = {
                enable = true;
                installCargo = false;
                installRustc = false;
              };
              bashls.enable = true;
              gopls.enable = true;
            };
          };

          # Format-on-save with a runtime toggle: the `format_on_save`
          # callback checks `vim.g.disable_autoformat` and `vim.b…`, so
          # `<Leader>uf` / `<Leader>uF` (below) can flip formatting on
          # the fly without rebuilding.
          conform-nvim = {
            enable = true;
            settings = {
              format_on_save.__raw = ''
                function(bufnr)
                  if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                  end
                  return { timeout_ms = 1000, lsp_format = "fallback" }
                end
              '';
              formatters_by_ft = {
                lua = [ "stylua" ];
                nix = [ "nixfmt" ];
                javascript = [ "prettier" ];
                typescript = [ "prettier" ];
                javascriptreact = [ "prettier" ];
                typescriptreact = [ "prettier" ];
                json = [ "prettier" ];
                yaml = [ "prettier" ];
                markdown = [ "prettier" ];
                python = [ "ruff_format" ];
                rust = [ "rustfmt" ];
                bash = [ "shfmt" ];
                sh = [ "shfmt" ];
                zsh = [ "shfmt" ];
                go = [ "gofumpt" ];
              };
            };
          };
        };

        # Skip bundling pkgs.claude-code into the neovim wrapper. The
        # plugin will pick the `claude` binary up from the shell's PATH
        # (Homebrew / npm-global / etc.) at runtime. Avoids forcing the
        # unfree claude-code package through the wrapper's PATH builder
        # — which makes the entire darwin-rebuild fail even when the
        # system pkgs is configured to allow unfree.
        dependencies.claude-code.enable = mkIf cfg.claudeCode.enable false;

        # Lua glue: which-key group labels, lazygit floating terminal,
        # and the format-on-save toggle that the keymaps below call.
        extraConfigLua = ''
          -- which-key group labels (v3 spec API)
          local ok_wk, wk = pcall(require, "which-key")
          if ok_wk then
            wk.add({
              { "<leader>b", group = "Buffer" },
              { "<leader>f", group = "Find" },
              { "<leader>g", group = "Git" },
              { "<leader>l", group = "LSP" },
              { "<leader>S", group = "Session" },
              { "<leader>t", group = "Terminal" },
              { "<leader>u", group = "UI Toggle" },
              { "<leader>x", group = "Trouble / Lists" },
              { "<leader>a", group = "AI" },
            })
          end

          -- Singleton floating lazygit terminal, backed by toggleterm.
          local Terminal = require("toggleterm.terminal").Terminal
          local lazygit = Terminal:new({
            cmd = "lazygit",
            hidden = true,
            direction = "float",
            float_opts = { border = "curved" },
          })
          function _G.LazygitToggle() lazygit:toggle() end

          -- Format-on-save toggle. Buffer-local first, falls back to global.
          function _G.ToggleAutoformat(scope)
            if scope == "buffer" then
              vim.b.disable_autoformat = not vim.b.disable_autoformat
              vim.notify("Autoformat (buffer): " ..
                (vim.b.disable_autoformat and "OFF" or "ON"))
            else
              vim.g.disable_autoformat = not vim.g.disable_autoformat
              vim.notify("Autoformat (global): " ..
                (vim.g.disable_autoformat and "OFF" or "ON"))
            end
          end

          ${optionalString cfg.neoTree.autoStart ''
          -- Open neo-tree on startup without taking focus.
          vim.api.nvim_create_autocmd("VimEnter", {
            callback = function() vim.cmd("Neotree show") end,
          })
          ''}

          -- Close-all-buffers-but-current — small helper for `<Leader>bC`.
          function _G.CloseOtherBuffers()
            local cur = vim.api.nvim_get_current_buf()
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
              if b ~= cur and vim.api.nvim_buf_is_loaded(b) then
                pcall(vim.api.nvim_buf_delete, b, {})
              end
            end
          end
        '';

        # Port of AstroNvim's default mapping tables. Grouped by leader
        # prefix; group labels above (which-key) make the menus discoverable.
        keymaps = [
          # ─── General ────────────────────────────────────────────────
          (nmap "<S-h>" "<cmd>bprevious<cr>" "Previous buffer")
          (nmap "<S-l>" "<cmd>bnext<cr>" "Next buffer")
          (nmap "]b"    "<cmd>bnext<cr>"     "Next buffer")
          (nmap "[b"    "<cmd>bprevious<cr>" "Previous buffer")
          (nmap "<C-q>" "<cmd>qa<cr>"  "Force quit")
          (nmap "|"     "<cmd>vsplit<cr>" "Vertical split")
          (nmap "\\"    "<cmd>split<cr>"  "Horizontal split")
          (nmap "<C-Up>"    "<cmd>resize +2<cr>"          "Resize split up")
          (nmap "<C-Down>"  "<cmd>resize -2<cr>"          "Resize split down")
          (nmap "<C-Left>"  "<cmd>vertical resize -2<cr>" "Resize split left")
          (nmap "<C-Right>" "<cmd>vertical resize +2<cr>" "Resize split right")
          (nmap "n" "nzzzv" "Next search (centered)")
          (nmap "N" "Nzzzv" "Prev search (centered)")
          (nmap "Y" "y$"    "Yank to end of line")

          # ─── Top-level AstroNvim defaults ───────────────────────────
          (nmap "<Leader>e" "<cmd>Neotree toggle<cr>" "Toggle Explorer")
          (nmap "<Leader>o" "<cmd>Neotree focus<cr>"  "Focus Explorer")
          (nmap "<Leader>w" "<cmd>w<cr>"  "Save")
          (nmap "<Leader>W" "<cmd>wa<cr>" "Save all")
          (nmap "<Leader>q" "<cmd>confirm q<cr>"  "Quit")
          (nmap "<Leader>Q" "<cmd>confirm qa<cr>" "Quit all")
          (nmap "<Leader>n" "<cmd>enew<cr>" "New file")
          (nmap "<Leader>/" "<Plug>(comment_toggle_linewise_current)" "Toggle comment")
          (vmap "<Leader>/" "<Plug>(comment_toggle_linewise_visual)"  "Toggle comment")

          # TODO-comment navigation (todo-comments.nvim).
          (nmap "]t" "<cmd>lua require('todo-comments').jump_next()<cr>" "Next TODO")
          (nmap "[t" "<cmd>lua require('todo-comments').jump_prev()<cr>" "Previous TODO")

          # ─── Buffer (<Leader>b) ─────────────────────────────────────
          (nmap "<Leader>c"  "<cmd>bdelete<cr>" "Close buffer")
          (nmap "<Leader>bd" "<cmd>bdelete<cr>" "Close buffer")
          (nmap "<Leader>bn" "<cmd>bnext<cr>"     "Next buffer")
          (nmap "<Leader>bp" "<cmd>bprevious<cr>" "Previous buffer")
          (nmap "<Leader>bC" "<cmd>lua CloseOtherBuffers()<cr>" "Close all buffers but current")
          # Bufferline sort modes (AstroNvim's b{se,si,sr,sm}).
          (nmap "<Leader>bse" "<cmd>BufferLineSortByExtension<cr>"     "Sort buffers by extension")
          (nmap "<Leader>bsi" "<cmd>BufferLineSortByDirectory<cr>"     "Sort buffers by directory")
          (nmap "<Leader>bsr" "<cmd>BufferLineSortByRelativeDirectory<cr>" "Sort buffers by rel dir")
          (nmap "<Leader>bsm" "<cmd>BufferLineSortByTabs<cr>"          "Sort buffers by tab")

          # ─── Find (<Leader>f) — telescope ───────────────────────────
          (nmap "<Leader>ff" "<cmd>Telescope find_files<cr>"                 "Find files")
          (nmap "<Leader>fF" "<cmd>Telescope find_files hidden=true<cr>"     "Find files (hidden)")
          (nmap "<Leader>fw" "<cmd>Telescope live_grep<cr>"                  "Find words")
          (nmap "<Leader>fW" "<cmd>Telescope live_grep additional_args={'--hidden'}<cr>" "Find words (hidden)")
          (nmap "<Leader>fb" "<cmd>Telescope buffers<cr>"                    "Find buffers")
          (nmap "<Leader>fh" "<cmd>Telescope help_tags<cr>"                  "Find help")
          (nmap "<Leader>fk" "<cmd>Telescope keymaps<cr>"                    "Find keymaps")
          (nmap "<Leader>fc" "<cmd>Telescope grep_string<cr>"                "Grep word under cursor")
          (nmap "<Leader>fC" "<cmd>Telescope commands<cr>"                   "Find commands")
          (nmap "<Leader>fo" "<cmd>Telescope oldfiles<cr>"                   "Find old files")
          (nmap "<Leader>f/" "<cmd>Telescope current_buffer_fuzzy_find<cr>"  "Find in current buffer")
          (nmap "<Leader>fm" "<cmd>Telescope marks<cr>"                      "Find marks")
          (nmap "<Leader>fr" "<cmd>Telescope registers<cr>"                  "Find registers")
          (nmap "<Leader>ft" "<cmd>Telescope colorscheme<cr>"                "Find colorscheme")
          (nmap "<Leader>fq" "<cmd>Telescope quickfix<cr>"                   "Find quickfix")
          (nmap "<Leader>fl" "<cmd>Telescope loclist<cr>"                    "Find loclist")
          (nmap "<Leader>fn" "<cmd>Telescope notify<cr>"                     "Find notifications")
          (nmap "<Leader>fa" "<cmd>Telescope autocommands<cr>"               "Find autocommands")
          (nmap "<Leader>f'" "<cmd>Telescope marks<cr>"                      "Find marks")
          (nmap "<Leader>fT" "<cmd>Telescope filetypes<cr>"                  "Find filetypes")
          (nmap "<Leader>xt" "<cmd>TodoTelescope<cr>"                        "Find TODOs")
          (nmap "<Leader>f<CR>" "<cmd>Telescope resume<cr>"                  "Resume last picker")

          # LSP source action (distinct from <Leader>la code action).
          # AstroNvim binds source action to lA via lsp.buf.code_action with `only` filter.

          # ─── Git (<Leader>g) ────────────────────────────────────────
          (nmap "<Leader>gg" "<cmd>lua LazygitToggle()<cr>" "Lazygit (floating)")
          (nmap "<Leader>gb" "<cmd>Telescope git_branches<cr>" "Git branches")
          (nmap "<Leader>gc" "<cmd>Telescope git_commits<cr>"  "Git commits")
          (nmap "<Leader>gC" "<cmd>Telescope git_bcommits<cr>" "Git buffer commits")
          (nmap "<Leader>gd" "<cmd>Gitsigns diffthis<cr>"      "Git diff")
          (nmap "<Leader>gj" "<cmd>Gitsigns next_hunk<cr>"     "Next git hunk")
          (nmap "<Leader>gk" "<cmd>Gitsigns prev_hunk<cr>"     "Prev git hunk")
          (nmap "<Leader>gp" "<cmd>Gitsigns preview_hunk<cr>"  "Preview git hunk")
          (nmap "<Leader>gr" "<cmd>Gitsigns reset_hunk<cr>"    "Reset git hunk")
          (nmap "<Leader>gR" "<cmd>Gitsigns reset_buffer<cr>"  "Reset git buffer")
          (nmap "<Leader>gs" "<cmd>Gitsigns stage_hunk<cr>"    "Stage git hunk")
          (nmap "<Leader>gS" "<cmd>Gitsigns stage_buffer<cr>"  "Stage git buffer")
          (nmap "<Leader>gu" "<cmd>Gitsigns undo_stage_hunk<cr>" "Undo stage hunk")
          (nmap "<Leader>gB" "<cmd>Gitsigns blame_line<cr>"    "Blame current line")
          (nmap "<Leader>gl" "<cmd>Gitsigns toggle_current_line_blame<cr>" "Toggle line blame")

          # ─── LSP (<Leader>l) ────────────────────────────────────────
          (nmap "<Leader>la" "<cmd>lua vim.lsp.buf.code_action()<cr>" "Code action")
          (nmap "<Leader>lA" "<cmd>lua vim.lsp.buf.code_action({ context = { only = { 'source' }, diagnostics = {} } })<cr>" "Source action")
          (nmap "<Leader>lr" "<cmd>lua vim.lsp.buf.rename()<cr>"      "Rename symbol")
          (nmap "<Leader>lh" "<cmd>lua vim.lsp.buf.hover()<cr>"       "Hover")
          (nmap "<Leader>lg" "<cmd>lua vim.lsp.buf.signature_help()<cr>" "Signature help")
          (nmap "<Leader>lf" "<cmd>lua require('conform').format({ async = true, lsp_format = 'fallback' })<cr>" "Format buffer")
          (nmap "<Leader>ld" "<cmd>lua vim.diagnostic.open_float()<cr>" "Line diagnostics")
          (nmap "<Leader>lD" "<cmd>Telescope diagnostics<cr>"           "Search diagnostics")
          (nmap "<Leader>lR" "<cmd>Telescope lsp_references<cr>"        "References")
          (nmap "<Leader>lG" "<cmd>Telescope lsp_workspace_symbols<cr>" "Workspace symbols")
          (nmap "<Leader>ls" "<cmd>Telescope lsp_document_symbols<cr>"  "Document symbols")
          (nmap "<Leader>lS" "<cmd>AerialToggle!<cr>"                   "Toggle symbol outline (Aerial)")
          (nmap "<Leader>li" "<cmd>LspInfo<cr>"                         "LSP info")
          (nmap "<Leader>ll" "<cmd>lua vim.lsp.codelens.refresh()<cr>"  "Codelens refresh")
          (nmap "<Leader>lL" "<cmd>lua vim.lsp.codelens.run()<cr>"      "Codelens run")
          (nmap "gd"         "<cmd>lua vim.lsp.buf.definition()<cr>"    "Go to definition")
          (nmap "gD"         "<cmd>lua vim.lsp.buf.declaration()<cr>"   "Go to declaration")
          (nmap "gI"         "<cmd>lua vim.lsp.buf.implementation()<cr>" "Go to implementation")
          (nmap "gy"         "<cmd>lua vim.lsp.buf.type_definition()<cr>" "Go to type def")
          (nmap "K"          "<cmd>lua vim.lsp.buf.hover()<cr>"          "Hover")
          (nmap "[d"         "<cmd>lua vim.diagnostic.goto_prev()<cr>"   "Prev diagnostic")
          (nmap "]d"         "<cmd>lua vim.diagnostic.goto_next()<cr>"   "Next diagnostic")

          # ─── UI Toggle (<Leader>u) ──────────────────────────────────
          (nmap "<Leader>uw" "<cmd>set wrap!<cr>"         "Toggle wrap")
          (nmap "<Leader>us" "<cmd>set spell!<cr>"        "Toggle spell")
          (nmap "<Leader>ul" "<cmd>set number!<cr>"       "Toggle line numbers")
          (nmap "<Leader>uN" "<cmd>set relativenumber!<cr>" "Toggle relative numbers")
          (nmap "<Leader>ug" "<cmd>lua vim.opt.signcolumn = (vim.opt.signcolumn:get() == 'yes' and 'no' or 'yes')<cr>" "Toggle signcolumn")
          (nmap "<Leader>uh" "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>" "Toggle inlay hints")
          (nmap "<Leader>ui" "<cmd>IBLToggle<cr>"         "Toggle indent guides")
          (nmap "<Leader>ud" "<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<cr>" "Toggle diagnostics")
          (nmap "<Leader>uD" "<cmd>lua vim.diagnostic.config({ virtual_text = not (vim.diagnostic.config().virtual_text or false) })<cr>" "Toggle virtual diagnostics")
          (nmap "<Leader>uf" "<cmd>lua ToggleAutoformat('global')<cr>" "Toggle autoformat (global)")
          (nmap "<Leader>uF" "<cmd>lua ToggleAutoformat('buffer')<cr>" "Toggle autoformat (buffer)")
          (nmap "<Leader>uc" "<cmd>lua vim.b.completion_disabled = not vim.b.completion_disabled; vim.notify('Completion (buffer): ' .. (vim.b.completion_disabled and 'OFF' or 'ON'))<cr>" "Toggle completion (buffer)")
          (nmap "<Leader>uy" "<cmd>set syntax=on<cr>"     "Reset syntax")

          # ─── Terminal (<Leader>t) ───────────────────────────────────
          # <C-\> already opens toggleterm via open_mapping above.
          (nmap "<Leader>tf" "<cmd>ToggleTerm direction=float<cr>"      "Floating terminal")
          (nmap "<Leader>th" "<cmd>ToggleTerm direction=horizontal<cr>" "Horizontal terminal")
          (nmap "<Leader>tv" "<cmd>ToggleTerm direction=vertical size=60<cr>" "Vertical terminal")
          (nmap "<Leader>tl" "<cmd>lua LazygitToggle()<cr>"             "Lazygit")
          (nmap "<Leader>tg" "<cmd>lua LazygitToggle()<cr>"             "Lazygit")
          (nmap "<Leader>tn" "<cmd>TermExec cmd=node direction=float<cr>"   "Node REPL")
          (nmap "<Leader>tp" "<cmd>TermExec cmd=python direction=float<cr>" "Python REPL")
          (nmap "<Leader>tt" "<cmd>TermExec cmd=btop direction=float<cr>"   "btop")
          # In terminal mode, <Esc> escapes to normal mode (AstroNvim default).
          (tmap "<Esc>" "<C-\\><C-n>" "Exit terminal mode")
          # Send a literal newline (LF, i.e. <C-j>) on Shift+Enter inside a
          # :terminal so multiline-input TUIs like Claude Code can tell it
          # apart from Enter. Only fires when the outer terminal actually
          # delivers a distinct Shift+Enter (Ghostty & other kitty-protocol
          # terminals); elsewhere it lies dormant and <C-j> still works.
          (tmap "<S-CR>" "<C-j>" "Newline (multiline TUI input)")

          # ─── Session (<Leader>S) — persistence.nvim ─────────────────
          (nmap "<Leader>Sl" "<cmd>lua require('persistence').load({ last = true })<cr>" "Load last session")
          (nmap "<Leader>S." "<cmd>lua require('persistence').load()<cr>" "Load session for cwd")
          (nmap "<Leader>Ss" "<cmd>lua require('persistence').save()<cr>" "Save session")
          (nmap "<Leader>Sd" "<cmd>lua require('persistence').stop()<cr>" "Stop session (don't save)")
          (nmap "<Leader>Sf" "<cmd>lua require('persistence').select()<cr>" "Find session")
        ] ++ optionals cfg.claudeCode.enable [
          # ─── AI / Claude Code (<Leader>a) ───────────────────────────
          (nmap "<Leader>ac" "<cmd>ClaudeCode<cr>"         "Toggle Claude Code")
          (nmap "<Leader>aC" "<cmd>ClaudeCodeContinue<cr>" "Claude continue last session")
          (nmap "<Leader>ar" "<cmd>ClaudeCodeResume<cr>"   "Claude resume picker")
        ];

        extraPackages = with pkgs; [
          # LSP servers
          nil
          lua-language-server
          typescript-language-server
          pyright
          rust-analyzer
          bash-language-server
          gopls
          # Formatters
          stylua
          nixfmt
          prettier
          ruff
          rustfmt
          shfmt
          gofumpt
          # Tools shelled-out to from keymaps
          lazygit
        ];
      };
    };
}
