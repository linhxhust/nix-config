{ config, ... }: {
  imports = [ ../user-configurations ];
  config = {
    programs.go = {
      enable = true;
      env = {
       GOPATH = "/Users/linhnguyen/Tools";
      };
    };
  };
}
