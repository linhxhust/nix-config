{ config, lib, pkgs, ... }:

let
  authKeyPath = "${config.home.homeDirectory}/.config/tailscale-auth-key";
in
{
  options.tailscaleOpts.installPackage = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Install the tailscale CLI from nixpkgs. Disable on hosts where the
      tailscale client and tailscaled daemon are provided by the OS, to
      avoid client/daemon version skew.
    '';
  };

  config = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
    home.packages = lib.optional config.tailscaleOpts.installPackage pkgs.tailscale;

    systemd.user.services.tailscale-up = {
      Unit = {
        Description = "Authenticate Tailscale using the user auth key";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "tailscale-up" ''
          set -eu

          if [ ! -s ${lib.escapeShellArg authKeyPath} ]; then
            echo "Tailscale auth key not found at ${lib.escapeShellArg authKeyPath}; skipping tailscale up."
            exit 0
          fi

          if ${lib.getExe pkgs.tailscale} status --json | ${lib.getExe pkgs.jq} -e '.BackendState == "Running"' >/dev/null; then
            echo "Tailscale is already running; skipping tailscale up."
            exit 0
          fi

          ${lib.getExe pkgs.tailscale} up --auth-key "$(cat ${lib.escapeShellArg authKeyPath})"
        '';
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
