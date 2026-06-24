{ lib, pkgs, config, ... }:

{
  config = lib.mkIf config.dotfiles.enable {
    programs.htop = {
      enable = true;
      settings = {
        # Display options
        show_cpu_frequency = true;
        show_cpu_temperature = true;
        show_cpu_usage = true;
        show_program_path = false;
        show_thread_names = true;
        show_tree_view = false;
        sort_key = "PERCENT_CPU";
        sort_direction = -1;
        
        # Meters
        left_meters = [ "AllCPUs2" "Memory" "Swap" ];
        right_meters = [ "Tasks" "LoadAverage" "Uptime" ];
        
        # Tree view
        tree_view = false;
        tree_view_always_by_pid = false;
        
        # Other options
        hide_kernel_threads = true;
        hide_userland_threads = false;
        highlight_base_name = false;
        highlight_megabytes = true;
        highlight_threads = true;
        shadow_other_users = false;
        show_threads = true;
        update_process_names = false;
        
        # Fields
        fields = [
          "PID"
          "USER"
          "PRIORITY"
          "NICE"
          "M_SIZE"
          "M_RESIDENT"
          "M_SHARE"
          "STATE"
          "PERCENT_CPU"
          "PERCENT_MEM"
          "TIME"
          "COMM"
        ];
      };
    };
  };
}
