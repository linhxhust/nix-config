# Store all declaration of user configurations for feature modules
{ lib, pkgs, ... }:
with lib; {
  options.userConf = {
    terminalFontSize = mkOption {
      type = types.float;
      description = "Terminal emulation font size";
      default = 10.0;
    };
    gitGpgSSHSignProgram = mkOption {
      type = types.nullOr types.str;
      description = "Absolute path to SSH signing program (e.g. op-ssh-sign). Null disables SSH commit signing.";
      default = null;
    };
    gitFolderConfigs = mkOption {
      type = types.attrsOf types.str;
      description = "custom per folder configuration for git ";
    };
    shellProgram = mkOption {
      type = types.str;
      description = "path to shell program";
      default = "${pkgs.zsh}/bin/zsh";
    };
  };
}
