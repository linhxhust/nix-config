{ config, ... }: {
  imports = [ ../user-configurations ];
  config = {
    programs.go = {
      enable = true;
      goPath = "/Users/linhnguyen/Tools";
    };
  };
}
