{ pkgs, ... }: {
  imports = [ ../user-configurations ];
  config = {
    home.packages = with pkgs; [
      rustc
      cargo
      clippy
      rustfmt
    ];
  };
}
