{ lib, pkgs, config, ... }:

{
  config = lib.mkIf config.dotfiles.enable {
    home = {
      enableNixpkgsReleaseCheck = false;
      stateVersion = lib.mkDefault "25.05";
    };
  };
}
