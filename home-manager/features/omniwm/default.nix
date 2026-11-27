{ config, lib, pkgs, ... }:

let
  cfg = config.omniwmOpts;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  options.omniwmOpts = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable the OmniWM tiling window manager. Importing this feature turns
        it on by default; set to false to keep the import but disable it.
      '';
    };

    settings = lib.mkOption {
      type = with lib.types; either path attrs;
      default = { };
      description = ''
        Forwarded to `programs.omniwm.settings` (attrset serialized to TOML,
        or a path to a TOML file). Empty means OmniWM manages its own
        settings.toml from the GUI.
      '';
    };

    launchd.keepAlive = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Restart OmniWM automatically if it exits (macOS launchd).";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # OmniWM is macOS-only (nixpkgs: platforms = [ "aarch64-darwin" ]) and the
    # home-manager module asserts Darwin, so only wire it up there.
    (lib.mkIf isDarwin {
      programs.omniwm = {
        enable = true;
        inherit (cfg) settings;
        launchd.keepAlive = cfg.launchd.keepAlive;
      };
    })

    # Importing on Linux (e.g. hp-prodesk) is safe: it evaluates to a no-op
    # with a warning, so the feature can be shared across hosts. Plug a Linux
    # tiling WM (e.g. niri, which OmniWM is modelled on) in here when needed.
    (lib.mkIf (!isDarwin) {
      warnings = [
        "omniwmOpts.enable is set, but OmniWM only supports macOS; skipping on ${pkgs.stdenv.hostPlatform.system}."
      ];
    })
  ]);
}
