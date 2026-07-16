# Self-hosted GitHub Actions runners as systemd user services.
#
# Each entry in `githubRunners` pairs one runner with one GitHub repository.
# Auth uses a token file that holds either a GitHub PAT (repo admin scope) or a
# short-lived registration token; the runner binary exchanges a PAT for a
# registration token itself, so a PAT survives service restarts.
#
# On a non-NixOS host you must enable lingering so the units run without an
# active login session:
#
#   sudo loginctl enable-linger "$USER"
#   systemctl --user daemon-reload
#   systemctl --user enable --now github-runner-<name>
{ config, lib, pkgs, ... }:

let
  cfg = config.githubRunners;

  runnerModule = { name, ... }: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to run this GitHub Actions runner.";
      };

      url = lib.mkOption {
        type = lib.types.str;
        example = "https://github.com/owner/repo";
        description = "URL of the GitHub repository this runner is paired with.";
      };

      tokenFile = lib.mkOption {
        type = lib.types.str;
        example = "/home/linhnguyen/.config/github-runner/repo.token";
        description = ''
          Path to a file containing a GitHub PAT (with repo administration
          scope) or a runner registration token. The file is read at service
          start; a PAT is preferred because it lets the runner re-register
          across restarts.
        '';
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Runner name as shown in the repository settings.";
      };

      labels = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "self-hosted" "linux" ];
        description = "Extra labels to assign to the runner.";
      };

      replace = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Replace any existing runner with the same name on registration.";
      };

      extraConfigArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Extra arguments passed to `Runner.Listener configure`.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.github-runner;
        defaultText = lib.literalExpression "pkgs.github-runner";
        description = "The github-runner package to use.";
      };
    };
  };

  enabledRunners = lib.filterAttrs (_: r: r.enable) cfg;

  # Tools a job (and the runner itself) typically needs on PATH. Appended with
  # the OS paths so non-NixOS hosts still find system binaries.
  runnerPath = lib.makeBinPath [
    pkgs.git
    pkgs.coreutils
    pkgs.bash
    pkgs.gnutar
    pkgs.gzip
    pkgs.gnused
    pkgs.gawk
    pkgs.gnugrep
    pkgs.which
  ];

  mkService = key: runner:
    let
      stateDir = "${config.home.homeDirectory}/.local/share/github-runner/${key}";

      configureScript = pkgs.writeShellScript "github-runner-${key}-configure" ''
        set -eu

        export HOME=${lib.escapeShellArg stateDir}
        export RUNNER_ROOT=${lib.escapeShellArg stateDir}

        mkdir -p ${lib.escapeShellArg stateDir}/_work
        cd ${lib.escapeShellArg stateDir}

        # Already registered: nothing to do.
        if [ -e ${lib.escapeShellArg stateDir}/.runner ]; then
          echo "Runner ${runner.name} already configured; skipping registration."
          exit 0
        fi

        token="$(cat ${lib.escapeShellArg runner.tokenFile})"
        case "$token" in
          ghp_*|github_pat_*) auth=(--pat "$token") ;;
          *)                  auth=(--token "$token") ;;
        esac

        ${runner.package}/bin/Runner.Listener configure \
          --unattended \
          --disableupdate \
          --url ${lib.escapeShellArg runner.url} \
          --name ${lib.escapeShellArg runner.name} \
          --work _work \
          ${lib.optionalString (runner.labels != [ ])
            "--labels ${lib.escapeShellArg (lib.concatStringsSep "," runner.labels)}"} \
          ${lib.optionalString runner.replace "--replace"} \
          ${lib.escapeShellArgs runner.extraConfigArgs} \
          "''${auth[@]}"
      '';

      runScript = pkgs.writeShellScript "github-runner-${key}-run" ''
        set -eu

        export HOME=${lib.escapeShellArg stateDir}
        export RUNNER_ROOT=${lib.escapeShellArg stateDir}

        cd ${lib.escapeShellArg stateDir}
        exec ${runner.package}/bin/Runner.Listener run --startuptype service
      '';
    in
    lib.nameValuePair "github-runner-${key}" {
      Unit = {
        Description = "GitHub Actions runner '${runner.name}' for ${runner.url}";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        Environment = [ "PATH=${runnerPath}:/usr/local/bin:/usr/bin:/bin" ];
        ExecStartPre = "${configureScript}";
        ExecStart = "${runScript}";
        Restart = "always";
        RestartSec = "10s";
      };

      Install.WantedBy = [ "default.target" ];
    };

in
{
  options.githubRunners = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule runnerModule);
    default = { };
    example = lib.literalExpression ''
      {
        my-repo = {
          url = "https://github.com/owner/my-repo";
          tokenFile = "/home/linhnguyen/.config/github-runner/my-repo.token";
          labels = [ "self-hosted" "linux" "hp-prodesk" ];
        };
      }
    '';
    description = "Self-hosted GitHub Actions runners, one per repository.";
  };

  config = lib.mkIf (enabledRunners != { }) {
    assertions = [{
      assertion = !pkgs.stdenv.hostPlatform.isDarwin;
      message = "githubRunners uses systemd user services and is only supported on Linux hosts.";
    }];

    systemd.user.services = lib.mapAttrs' mkService enabledRunners;
  };
}
