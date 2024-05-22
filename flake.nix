{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixvim, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        simplePluginsList = [
          "lualine"
          "bufferline"
          "harpoon"
          "luasnip"
          "cmp_luasnip"
          "cmp-buffer"
          "cmp-calc"
          "cmp-path"
          "nvim-tree"
        ];

        simplePluginsList' = {
          plugins = lib.genAttrs simplePluginsList (_: { enable = true; });
        };

        imap = key: action: {
          mode = "i";
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

        map =
          key:
          action:
          {
            key = key;
            action = action;
            options.silent = true;
          };

        defaultSettings = {
          enableMan = false;
          colorschemes.gruvbox.enable = true;

          plugins = {
            telescope = {
              enable = true;
              keymaps = {
                "<leader>ff" = "find_files";
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
                  { name = "luasnip"; }
                  { name = "buffer"; }
                  { name = "calc"; }
                  { name = "path"; }
                ];

                preselect = "cmp.PreselectMode.None";

                mapping = {
                  "<CR>" = "cmp.mapping.confirm({ select = true })";
                  "<C-p>" = "cmp.mapping.select_prev_item()";
                  "<C-n>" = "cmp.mapping.select_next_item()";
                  "<C-Space>" = "cmp.mapping.complete()";
                  "<C-e>" = "cmp.mapping.close()";
                  "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                  "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
                };
              };
            };

            treesitter = {
              enable = true;
              ensureInstalled = [ ];
            };
          };

          keymaps = [
            (imap "jk" "<esc>")

            (nmap "<C-n>" ":NvimTreeToggle<CR>")
            (nmap "<Esc>" ":noh<CR>")
            (nmap "H" "^")
            (nmap "L" "$")
            (nmap "<right>" "<cmd>bn<CR>")
            (nmap "<left>" "<cmd>bp<CR>")
            (nmap ";w" ":w<CR>")

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

        };

        cfg' = lib.recursiveUpdate simplePluginsList' defaultSettings;
        meow' = cfg: nixvim.legacyPackages.${system}.makeNixvim cfg;

      in
      rec

      {
        cfg = cfg';
        meow = meow';
        devShells.default = pkgs.mkShell {
          buildInputs = [ meow cfg ];
        };
      }
    );
}
