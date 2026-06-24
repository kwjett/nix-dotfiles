# NOTE: not imported by default (commented in default.nix). The internal-host
# blocks below reference `vars.system.domain`, which used to be threaded in
# from a NixOS-level `_module.args.vars`. Standalone home-manager consumers
# who want these blocks should provide their own `vars` via
# `_module.args.vars = { ... };` before importing this module.
{ lib, pkgs, config, vars, ... }:

let
  cfg = config.dotfiles;
  home = config.home.homeDirectory;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks."*" = {
          # Default settings for all hosts
        };
        extraConfig = ''
          Host github.com
            Hostname github.com
            IdentitiesOnly yes
            IdentityFile ${home}/.ssh/id_github

          Host nixos-server
            Hostname nixos-server.${vars.system.domain}
            IdentitiesOnly yes
            IdentityFile ${home}/.ssh/id_ed25519

          Host nixos-test
            Hostname nixos-test.${vars.system.domain}
            IdentitiesOnly yes
            IdentityFile ${home}/.ssh/id_ed25519

          Host dns-02
            Hostname dns-02.${vars.system.domain}
            User nixpi
            IdentityFile ${home}/.ssh/id_ed25519

          Host dns-vm
            Hostname dns-01.${vars.system.domain}
            User kjett
            IdentityFile ${home}/.ssh/id_ed25519

          Host fileserver
            Hostname fileserver.${vars.system.domain}
            User kjett
            IdentityFile ${home}/.ssh/id_ed25519

          Host plasma-vm
            Hostname 192.168.67.5
            User kjett
            IdentityFile ${home}/.ssh/id_ed25519

          Host tailscale-router
            Hostname 10.0.1.20
            User kjett
            IdentityFile ${home}/.ssh/id_ed25519

          Host media-server
            Hostname media-server.${vars.system.domain}
            IdentitiesOnly yes
            IdentityFile ${home}/.ssh/id_ed25519
        '';
      };
    };
  };
}
