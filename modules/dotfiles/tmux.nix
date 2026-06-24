{ lib, pkgs, config, ... }:

let
  cfg = config.dotfiles;
  tokyo-night-tmux = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tokyo-night-tmux";
      rtpFilePath = "tokyo-night.tmux";
      version = "1.6.6";
      src = pkgs.fetchFromGitHub {
        owner = "janoamaral";
        repo = "tokyo-night-tmux";
        rev = "caf6cbb4c3a32d716dfedc02bc63ec8cf238f632";
        hash = "sha256-TOS9+eOEMInAgosB3D9KhahudW2i1ZEH+IXEc0RCpU0=";
      };
    };
in

{
  config = lib.mkIf cfg.enable {
    programs = {
      tmux = {
        enable = true;
        shell = "${pkgs.zsh}/bin/zsh";
        aggressiveResize = true;
        baseIndex = 1;
        clock24 = false;
        terminal = "xterm-256color";
        prefix = "C-x";
        historyLimit = 50000;
        mouse = true;
        #customPaneNavigationAndResize = true;
        escapeTime = 0;
        keyMode = "vi";
        shortcut = "Space";
        plugins = with pkgs.tmuxPlugins; [
          vim-tmux-navigator
          sensible
          yank
          prefix-highlight
          pain-control
          {
            ## https://github.com/janoamaral/tokyo-night-tmux
            plugin = tokyo-night-tmux;
            extraConfig = ''
              ### Tokyo Night Theme configuration
              set -g @tokyo-night-tmux_theme 'night'  # storm | day | default to 'night'
              set -g @tokyo-night-tmux_transparent 1  # 1 or 0

              set -g @tokyo-night-tmux_window_id_style hide
              set -g @tokyo-night-tmux_pane_id_style hide
              set -g @tokyo-night-tmux_zoom_id_style hide

              # Icon styles
              # set -g @tokyo-night-tmux_terminal_icon 
              # set -g @tokyo-night-tmux_active_terminal_icon 

              set -g @tokyo-night-tmux_window_tidy_icons 1

              set -g @tokyo-night-tmux_show_datetime 1
              set -g @tokyo-night-tmux_date_format MYD
              set -g @tokyo-night-tmux_time_format 12H
            '';
          }
          # tmux-resurrect: Saves and restores tmux sessions (windows, panes, layouts,
          # and working directories) across tmux server restarts. Use prefix + Ctrl-s
          # to save and prefix + Ctrl-r to manually restore.
          # {
          #     plugin = resurrect;
          #     extraConfig = ''
          #       set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
          #       set -g @resurrect-capture-pane-contents 'on'
          #       set -g @resurrect-pane-contents-area 'visible'
          #     '';
          # }
          # tmux-continuum: Works alongside resurrect to automatically save sessions
          # at a regular interval and auto-restore the last saved session when tmux
          # starts. This is what causes sessions to persist across reboots.
          # {
          #   plugin = continuum;
          #   extraConfig = ''
          #     set -g @continuum-restore 'on'
          #     set -g @continuum-save-interval '5' # minutes
          #   '';
          # }
        ];
        extraConfig = ''
          # Work around for issue where shell doesn't launch correctly
          set -gu default-command
          set -g default-shell "$SHELL"

          # enables clipboard in nested tmux sessions
          set -g set-clipboard on

          # Enable true color support
          set -ga terminal-overrides ",xterm-256color:Tc"

          # Set Bind Keys
          bind-key -n M-x kill-pane
          bind-key -n M-c new-window
          bind -n M-Right next-window
          bind -n M-Left previous-window
          bind-key -n M-h split-window -h
          bind-key -n M-v split-window -v
          bind-key -n M-o select-pane -t :.+
          bind-key M-a last-window
          bind-key -n F10 resize-pane -Z
          bind-key m set-option -g mouse on \; display 'Mouse: ON'
          bind-key M set-option -g mouse off \; display 'Mouse: OFF'
          bind-key -n C-Left select-pane -L
          bind-key -n C-Right select-pane -R
          bind-key -n C-Up select-pane -U
          bind-key -n C-Down select-pane -D
          bind-key -n C-S-Left resize-pane -L
          bind-key -n C-S-Right resize-pane -R
          bind-key -n M-y copy-mode
          bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -selection c"
          bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
          bind-key -T copy-mode-vi 'v' send -X begin-selection
          bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "xclip -in -selection clipboard"

          # Additional Options
          set-option -g status-position bottom
          # set-option -g allow-rename off
          # set-option -g status-interval 3
          # set-option -g automatic-rename on
          # set-option -g automatic-rename-format '#{b:pane_current_path}'
        '';
      };
    };
  };
}
