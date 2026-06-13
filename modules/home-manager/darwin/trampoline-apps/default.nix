# Hook home-manager to make a trampoline for each app we install
# from: https://github.com/nix-community/home-manager/issues/1341#issuecomment-1870352014
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.darwin.trampolineApps;
in {
  options.darwin.trampolineApps.extraApps = mkOption {
    type = types.listOf types.str;
    default = [ ];
    example = [ "/Applications/1Password.app" ];
    description = ''
      Extra macOS application bundles to expose as trampoline apps in
      ~/Applications/Home Manager Trampolines. This is useful for GUI apps
      that should not be installed into the Nix store on Darwin.
    '';
  };

  config = mkIf pkgs.stdenv.hostPlatform.isDarwin {
    # Install MacOS applications to the user Applications folder. Also update Docked applications
    home.extraActivationPath = with pkgs; [ rsync dockutil gawk ];
    home.activation.trampolineApps = hm.dag.entryAfter [ "writeBoundary" ] ''
      ${builtins.readFile ./lib-bash/trampoline-apps.sh}
      fromDir="$HOME/Applications/Home Manager Apps"
      toDir="$HOME/Applications/Home Manager Trampolines"
      extraApps=(${escapeShellArgs cfg.extraApps})
      sync_trampolines "$fromDir" "$toDir" "''${extraApps[@]}"
    '';
  };
}
