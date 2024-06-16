# kirara-nixvim

**kirara-nixvim** is a pre-configured [nixvim](https://github.com/nix-community/nixvim) distribution that I designed to share my configuration while also making it easier for me to integrate into my projects.

It is named in homage to Kirara, a beloved Genshin character of a [close friend and even better person](https://github.com/everlyy).

## Contents
The configuration includes:
- Selenized Theme
- Setup of LSP and CMP
- Quality of life plugins, such as: nvim-tree, gitsigns, harpoon and telescope
- Keybinds I often use
- A preset of neovim settings

**kirara-nixvim** holds this configuration, but does not apply it immediately. You can easily extend and modify it to suit your preferences before integrating it into your environment.

## Usage and Examples
This project is entirely flake-based. If you are not unfamiliar with these, [this guide](https://nixos.wiki/wiki/Flakes) will teach you how to enable and use them.

To use **kirara-nixvim**, there are two approaches:

### Option 1: Using the default configuration:
Adding this to your flake.nix will use **kirara-nixvim** as is:
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    kirara-nixvim.url = "github:hyperpastel/kirara-nixvim";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, kirara-nixvim, utils }:
    utils.lib.eachDefaultSystem (system:
      pkgs = nixpkgs.legacyPackges.${system};
      let
        nvim = kirara-nixvim.defaultPackage.${system};
        shellPackages = [
          # Other packages for the shell go here!
        ];
      in {
        # It is good practice to not force editor preferences onto others, so let's
        # make two devShells, one without and one with our generated nvim!
        devShells = {
          default = pkgs.mkShell { packages = shellPackages; };
          nvim = pkgs.mkShell { packages = shellPackages ++ [ nvim ]; };
        };
      });
}
```
### Option 2: Customizing the configuration:
You can customize **kirara-nixvim** just as you would customize nixvim itself. For example, let's add emoji support to cmp!
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    kirara-nixvim.url = "github:hyperpastel/kirara-nixvim";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, kirara-nixvim, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        kirara = kirara-nixvim.lib.${system};
        cfg = kirara.cfg;

        final-cfg = pkgs.lib.attrsets.recursiveUpdate cfg {
          plugins = {
            cmp-emoji.enable = true;
            cmp.settings.sources = cfg.plugins.cmp.settings.sources ++ [{ name = "emoji"; }];
          };
          keymaps = cfg.keymaps
            ++ [ (kirara.fn.nmap "<leader>bb" "<Cmd>echo \"Hello world from kirara-nixvim!\"<CR>") ];
        };

        nvim = kirara.meow final-cfg;

        shellPackages = [
          # Other packages for the shell go here!
        ];
      in {
        # It is good practice to not force editor preferences onto others, so let's
        # make two devShells, one without and one with our generated nvim!
        devShells = {
          default = pkgs.mkShell { packages = shellPackages; };
          nvim = pkgs.mkShell { packages = shellPackages ++ [ nvim ]; };
        };
      });
}
```

## Testing nixvim before usage
If you wish to test this distribution without integrating it into your projects or system, you can run the following to gain access to a shell with kirara-nixvim built and invocable as ``nvim``

```bash
nix shell github:hyperpastel/kirara-nixvim
```

## What does this flake provide?
This flake provides the ``nvim`` program, with **kirara-nixvim**'s configuration applied, as ``package.default`` (for nix run and nix shell), and also as ``defaultPackage``.

Additionally, it exposes a ``lib`` attribute set with the following attributes: 

| Attribute | Description |
| --- | --- |
| fn | Utility functions used primarily internally, helpful for further customization.|
| cfg | The default configuration of this distribution, extendable with ``recursiveUpdate``.|
| meow | Function expecting either ``cfg`` or a modified version thereof. Generates the final nixvim derivation using ``nixvim.makeNixvim``.|


## Debugging / Obtaining the generated lua config
This advice is not specific to this project, but more to nixvim itself. If, at any point, you wish to see what the init.lua file that nixvim generates looks
like, you can use this following command inside an environment that has a nixvim derivation.

```bash
which nvim | xargs grep -o '/nix/store/[^ ]*-init.lua'
```

This will print out the path of the current lua config that nixvim is using. You can then either copy that and use it however you like, or you could pipe again into ``xargs less`` to open it right away. 
