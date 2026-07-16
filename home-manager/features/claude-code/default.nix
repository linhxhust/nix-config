{ pkgs, ... }: {
  imports = [ ../user-configurations ];
  config = {
    home.packages = with pkgs; [
      claude-code
    ];
  };
}
