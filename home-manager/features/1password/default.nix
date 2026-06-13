{ lib, pkgs, ... }:

let
  onePasswordGui = pkgs._1password-gui;
in {
  imports = [ ../user-configurations ];

  home.packages = with pkgs; [
    _1password-cli
    onePasswordGui
  ];

  userConf.gitGpgSSHSignProgram = lib.getExe' onePasswordGui "op-ssh-sign";
}
