{ lib, pkgs, ... }:

let
  onePasswordGui = pkgs._1password-gui;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  imports = [ ../user-configurations ];

  home.packages = with pkgs;
    [ _1password-cli ] ++ lib.optionals (!isDarwin) [ onePasswordGui ];

  userConf.gitGpgSSHSignProgram = if isDarwin then
    "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  else
    lib.getExe' onePasswordGui "op-ssh-sign";
} // lib.optionalAttrs isDarwin {
  darwin.trampolineApps.extraApps = [ "/Applications/1Password.app" ];
}
