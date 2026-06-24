# nix-dotfiles

Personal dotfiles packaged as a reusable home-manager flake module. Configures
shell, prompt, multiplexer, system monitors, and (optionally) editor
environments. Works as a **standalone home-manager** module *or* as a
home-manager module loaded from NixOS / nix-darwin.

## Usage

Add as a flake input:

```nix
{
  inputs.dotfiles = {
    url = "github:kwjett/nix-dotfiles";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
}
```

### Standalone home-manager

In your `home.nix` (or whichever module home-manager loads):

```nix
{ inputs, ... }:
{
  imports = [ inputs.dotfiles.homeManagerModules.default ];

  dotfiles = {
    enable = true;
    editors.nixvim.enable = true;
  };
}
```

### NixOS / nix-darwin (with home-manager as a system module)

Import the module *inside* the `home-manager.users.<user>` block:

```nix
{ inputs, ... }:
{
  home-manager.users.alice = {
    imports = [ inputs.dotfiles.homeManagerModules.default ];

    dotfiles = {
      enable = true;
      editors.nixvim.enable = true;
    };
  };
}
```

## Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `dotfiles.enable` | bool | `false` | Master toggle |
| `dotfiles.editors.doomEmacs.enable` | bool | `false` | Provision Doom Emacs config |
| `dotfiles.editors.nixvim.enable` | bool | `false` | Provision pure-nixvim editor (declarative) |
| `dotfiles.editors.nixvim.claudeCode.enable` | bool | `false` | Embed Claude Code in an nvim split (`<Leader>ac` toggles) |

When `dotfiles.enable = true` and no editor flags are set, you still get zsh,
starship, tmux, direnv, htop, and btop configured.

The target user is whichever user home-manager is configuring — there is no
`dotfiles.user` option, since home-manager already knows that via
`config.home.username` / `config.home.homeDirectory`.

## What's included

- `zsh` with starship prompt and direnv hook
- `tmux` with sensible defaults
- `htop` / `btop` themed
- Optional: pure-nixvim editor (declarative — catppuccin, LSP, completion, neo-tree, treesitter, format-on-save)
- Optional: Doom Emacs config (`doom.d/`)

## License

AGPL-3.0 — see [LICENSE](./LICENSE).
