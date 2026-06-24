{
  description = "Personal dotfiles as a reusable home-manager module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, nix-doom-emacs-unstraightened, ... }:
    let
      # Bind upstream home-manager modules via a closure here at the
      # flake-output layer. We can't reference flake inputs via `_module.args`
      # from `imports` inside a sub-module — that produces infinite recursion
      # because `imports` is resolved before `config` during module merging.
      # Importing them unconditionally is fine: each upstream module's enable
      # option defaults to false, so it generates no config until our wrappers
      # under `editors/` turn it on via `dotfiles.editors.<name>.enable`.
      dotfilesModule = { ... }: {
        imports = [
          ./modules/dotfiles
          nixvim.homeModules.nixvim
          nix-doom-emacs-unstraightened.homeModule
        ];
      };
    in
    {
      # Pure home-manager module. Works with:
      #   - standalone home-manager (imported from your home.nix)
      #   - home-manager-as-NixOS-module (imported inside `home-manager.users.<user> = { ... };`)
      #   - home-manager-as-nix-darwin-module (same pattern as NixOS)
      homeManagerModules.default = dotfilesModule;
      homeManagerModules.dotfiles = dotfilesModule;
    };
}
