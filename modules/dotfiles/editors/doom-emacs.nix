{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.dotfiles.editors.doomEmacs;
in
{
  config = mkIf cfg.enable {
    programs.doom-emacs = {
      enable = true;
      doomDir = ./doom.d;
      emacs = pkgs.emacs-nox;
    };

    home.packages = with pkgs; [
      glow
      clang
      cmake
      gnumake
      python3
      isort
      shellcheck
      nixfmt
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.sauce-code-pro
    ];

    programs.zsh.shellAliases.doom = "emacs -nw";
  };
}
