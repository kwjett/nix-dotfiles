{ lib, config, pkgs, ... }:

with lib;

{
  imports = [
    ./home-manager.nix
    ./zsh.nix
    ./starship.nix
    ./direnv.nix
    ./tmux.nix
    #./ssh.nix
    #./helix.nix
    ./htop.nix
    ./btop.nix
    ./editors/doom-emacs.nix
    ./editors/nixvim.nix
  ];

  config = mkIf config.dotfiles.enable {
    # Configuration will be handled by the imported modules
  };

  options.dotfiles = {
    enable = mkEnableOption "dotfiles configuration";

    editors = {
      doomEmacs = {
        enable = mkEnableOption "Doom Emacs editor configuration";
      };

      nixvim = {
        enable = mkEnableOption "Pure-nixvim editor configuration";
        claudeCode.enable = mkEnableOption "Claude Code integration inside nvim (greggh/claude-code.nvim)";
      };
    };
  };
}
