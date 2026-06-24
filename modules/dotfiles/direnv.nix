{ lib, pkgs, config, ... }:

{
  config = lib.mkIf config.dotfiles.enable {
    programs = {
      # Shared shell configuration
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
