{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        simplePluginsList = [
          "harpoon"
          "cmp_luasnip"
          "cmp-calc"
          "cmp-nvim-lsp"
          "cmp-path"
          "nvim-tree"
          "nix"
          "friendly-snippets"
          "which-key"
          "gitsigns"
        ];

        simplePluginsList' = {
          plugins = lib.genAttrs simplePluginsList (_: {
            enable = true;
          });
        };

        imap = key: action: {
          mode = "i";
          key = key;
          action = action;
          options.silent = true;
        };

        vmap = key: action: {
          mode = "v";
          key = key;
          action = action;
          options.silent = true;
        };

        nmap = key: action: {
          mode = "n";
          key = key;
          action = action;
          options.silent = true;
        };

        map = key: action: {
          key = key;
          action = action;
          options.silent = true;
        };

        defaultSettings = {
          enableMan = false;
          colorschemes.base16 = {
            enable = true;
            # TODO Replace with selenized once available
            colorscheme = "solarized-light";
          };

          extraConfigLuaPre = ''
            package.preload["jsregexp"] = package.loadlib("${pkgs.lua51Packages.jsregexp}/lib/lua/5.1/jsregexp/core.so", "luaopen_jsregexp_core");

            local expand_snippet = function(fallback)
                local cmp = require("cmp")
                local luasnip = require("luasnip")

                if cmp.visible() then
                    if luasnip.expandable() then
                        luasnip.expand()
                    else
                        cmp.confirm({select = true})
                    end
                else
                    fallback()
                end
            end

            local jump_up = function(fallback)
                    local cmp = require("cmp")
                    local luasnip = require("luasnip")

                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif luasnip.locally_jumpable(num) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end


            local jump_down = function(fallback)
                    local cmp = require("cmp")
                    local luasnip = require("luasnip")

                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif luasnip.locally_jumpable(num) then
                        luasnip.jump(1)
                    else
                        fallback()
                    end
                end
          '';

          plugins = {
            telescope = {
              enable = true;
              keymaps = {
                "<leader>ff" = "find_files";
              };
            };

            luasnip = {
              enable = true;
              fromVscode = [ { } ];
            };

            lsp = {
              enable = true;
              servers = {
                nixd.enable = true;
                bashls.enable = true;
              };

              keymaps = {
                lspBuf = {
                  "<leader>f" = "format";
                  "<leader>r" = "rename";
                  "<leader>a" = "code_action";
                  K = "hover";
                  gD = "references";
                  gd = "definition";
                  gi = "implementation";
                  gt = "type_definition";
                };

                diagnostic = {
                  "<leader>e" = "open_float";
                };
                silent = true;
              };

            };

            cmp = {
              enable = true;
              autoEnableSources = true;

              settings = {
                snippet = {
                  expand = ''
                    function(args) 
                      require('luasnip').lsp_expand(args.body)
                    end'';
                };
                sources = [
                  { name = "nvim_lsp"; }
                  { name = "luasnip"; }
                  { name = "calc"; }
                  { name = "path"; }
                ];

                preselect = "cmp.PreselectMode.None";

                mapping = {
                  "<CR>" = "cmp.mapping(expand_snippet)";
                  "<C-p>" = "cmp.mapping.select_prev_item()";
                  "<C-n>" = "cmp.mapping.select_next_item()";
                  "<C-Space>" = "cmp.mapping.complete()";
                  "<C-e>" = "cmp.mapping.close()";
                  "<S-Tab>" = "cmp.mapping(jump_up, {'i', 's'})";
                  "<Tab>" = "cmp.mapping(jump_down, {'i', 's'})";
                };
              };
            };

          };

          keymaps = [
            (imap "jk" "<esc>")

            (nmap "<C-n>" "<Cmd>NvimTreeToggle<CR>")
            (nmap "<Esc>" "<Cmd>noh<CR>")
            (nmap "H" "^")
            (nmap "L" "$")
            (nmap "<right>" "<Cmd>bn<CR>")
            (nmap "<left>" "<Cmd>bp<CR>")
            (nmap "<leader>x" "<Cmd>bd<CR>")
            (nmap ";w" "<Cmd>w<CR>")

            (vmap "H" "^")
            (vmap "L" "$")

            (map "<C-h>" "<C-w>h")
            (map "<C-j>" "<C-w>j")
            (map "<C-k>" "<C-w>k")
            (map "<C-l>" "<C-w>l")

          ];

          globals = {
            encoding = "utf-8";
            nowrap = true;
            shiftwidth = 4;
            softtabstop = 4;
            tabstop = 4;
            noexpandtab = true;
            mapleader = " ";
          };

          opts = {
            number = true;
            relativenumber = true;
            guicursor = "a:block";
            signcolumn = "yes";
            completeopt = "menuone,noinsert,noselect";
            hidden = true;
            autoindent = true;
            splitright = true;
            shiftwidth = 2;
            timeoutlen = 300;
            updatetime = 300;
            cmdheight = 2;
            fillchars.eob = " ";
          };

          extraConfigLua = ''
            vim.diagnostic.config({
            	virtual_text = {
            	  prefix = "",
            	  format = function(diagnostic)
            	    if diagnostic.severity == vim.diagnostic.severity.ERROR then
            	      return string.format("🩸 %s", diagnostic.message)
            	    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
            	      return string.format("✨ %s", diagnostic.message)
                  elseif diagnostic.severity == vim.diagnostic.severity.INFO then
            	      return string.format("☔️ %s", diagnostic.message)
            	    else
            	      return string.format("💫 %s", diagnostic.message)
            	  end
            	end
            	}
              })
          '';

          extraConfigLuaPost = ''
            vim.cmd [[colorscheme base16-selenized-light]];
            '';

        };

        cfg' = lib.recursiveUpdate simplePluginsList' defaultSettings;
        meow' = cfg: nixvim.legacyPackages.${system}.makeNixvim cfg;

        fn' = {
          imap = imap;
          nmap = nmap;
          map = map;
        };

      in

      {
        package = {
          cfg = cfg';
          meow = meow';
          fn = fn';
          devShells.default = pkgs.mkShell { buildInputs = [ (meow' cfg') ]; };
        };
      }
    );
}
