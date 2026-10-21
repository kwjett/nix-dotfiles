{ lib, pkgs, config, ... }:

{
  config = lib.mkIf config.dotfiles.enable {
    programs = {
      zsh = {
        enable = true;
        autosuggestion.enable = false;
        syntaxHighlighting.enable = true;
        enableCompletion = true;
        autocd = false;
        cdpath = [ "~/.local/share/src" ];
        shellAliases = {
          g = "git";
          ls = "ls --color=auto";
          ll = "ls -alh";
          ltr = "ls -ltra";
          h = "history | tail";
          hg = "history | grep";
          root = "sudo su - root -c zsh";
          yeet = "git push --force";
          ffs = "sudo $(fc -ln -1)";
          nano = "vim"; # No one should ever use nano :)
          diff = "difft"; # Use difftastic, syntax-aware diffing
          search = "rg -p --glob '!node_modules/*'  $@"; # Ripgrep alias
        } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          dnsflush = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
        };
        history = {
          size = 10000;
          path = "$HOME/.zsh_history";
          extended = true;
          ignorePatterns = [ "pwd" "ls" "ll" "ll *" ]; # Remove history data we don't want to see
          ignoreSpace = true;
        };
        oh-my-zsh = {
          enable = true;
          plugins = [ "tmux" "macos" ];
        };
        sessionVariables = {
          # Advertise truecolor support to TUI apps. SSH does not forward
          # COLORTERM by default, so setting it in .zshenv ensures emacs &
          # friends render 24-bit theme palettes correctly over remote shells.
          COLORTERM = "truecolor";
        };
        # sessionVariables = {
        #   # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/tmux#configuration-variables
        #   # automatically start tmux
        #   ZSH_TMUX_AUTOSTART = "true";
        #   ZSH_TMUX_CONFIG = "$HOME/.config/tmux/tmux.conf";
        # };
        initContent = lib.mkBefore ''
          if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
            . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
          fi

          # Define variables for directories
          export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
          export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
          export PATH=$HOME/.local/share/bin:$PATH
          
          # Add homebrew to path
          export PATH=/opt/homebrew/bin:$PATH

          # Set keybindings for ctrl+r reverse history search
          bindkey -v
          bindkey '^R' history-incremental-search-backward

          # nix shortcuts
          shell() {
              nix-shell '<nixpkgs>' -A "$1"
          }

          ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin "\n            # Disable mouse reporting when prompt is shown (fixes ghost mouse input after SSH disconnect in Ghostty)\n            precmd_mouse_reset() { print -n \$'\\033[?1000l\\033[?1002l\\033[?1006l'; }\n            autoload -Uz add-zsh-hook\n            add-zsh-hook precmd precmd_mouse_reset"}
        '';
      };
    };
  };
}