{ lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  onePasswordGui = pkgs._1password-gui;
in {
  imports = [ ../user-configurations ];

  home.packages = with pkgs;
    [ _1password-cli ] ++ lib.optionals (!isDarwin) [ onePasswordGui ];

  darwin.trampolineApps.extraApps = lib.mkIf isDarwin [
    "/Applications/1Password.app"
  ];

  userConf.gitGpgSSHSignProgram = if isDarwin then
    "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  else
    lib.getExe' onePasswordGui "op-ssh-sign";
}
