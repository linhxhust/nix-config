{ lib, pkgs, ... }:

{
  imports = [ ../user-configurations ];

  config = lib.mkMerge [
    {
      home.packages =
        [ pkgs._1password-cli ]
        ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [ pkgs._1password-gui ];

      userConf.gitGpgSSHSignProgram =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else
          lib.getExe' pkgs._1password-gui "op-ssh-sign";
    }
    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      darwin.trampolineApps.extraApps = [
        "/Applications/1Password.app"
      ];
    })
  ];
}
