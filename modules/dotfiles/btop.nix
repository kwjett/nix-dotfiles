{ lib, pkgs, config, ... }:

{
  config = lib.mkIf config.dotfiles.enable {
    programs.btop = {
      enable = true;
      settings = {
        # Tokyo Night theme colors
        color_theme = "TTY";
        theme_background = true;

        # Update settings
        update_ms = 2000;
        
        # Process settings
        proc_sorting = "cpu lazy";
        proc_gradient = true;
        proc_per_core = true;
        proc_mem_bytes = true;
        
        # CPU settings
        cpu_invert_lower = true;
        
        # Memory settings
        mem_graphs = true;
        show_disks = true;
        only_physical = true;
        show_io_stat = true;
        
        # Box layout
        shown_boxes = "proc cpu mem net";
        
        # Clock format
        clock_format = "%H:%M";
        
        # Disk filter
        disks_filter = "exclude=/boot";
      };
    };
  };
}
