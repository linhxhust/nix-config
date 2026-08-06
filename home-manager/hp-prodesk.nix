{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./features/git
    ./features/zsh
    ./features/neovim
    ./features/go
    ./features/rust
    ./features/nushell
    ./features/tailscale
    ./features/github-runners
    ./features/user-configurations
    ./features/jellyfin
    ./features/tmux
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  home = {
    username = "linhnguyen";
    homeDirectory = "/home/linhnguyen";
    stateVersion = "23.05";
    packages = with pkgs; [
      nerd-fonts.inconsolata
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      hadolint
      uv
      awscli2
      terraform
      terraform-ls
      golangci-lint
      gopls
      kubectl
      kubernetes-helm
      tflint
      zoxide
      eza
      krew
      inetutils
      pwgen
      ansible
      markdownlint-cli
      azure-cli
      lazygit
      claude-code
    ];
  };

  programs.home-manager.enable = true;

  programs.go.env.GOPATH = lib.mkForce "/home/linhnguyen/tools/go";

  # tailscale (client + tailscaled) is provided by the OS on this non-NixOS host;
  # skip the nixpkgs CLI to avoid client/daemon version skew.
  tailscaleOpts.installPackage = false;

  userConf = {
    terminalFontSize = 12.0;
    gitFolderConfigs = { };
    shellProgram = "${pkgs.zsh}/bin/zsh";
  };

  tmuxOpts = {
    shell = config.userConf.shellProgram;
    prefix = "C-b";
  };

  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "frappe";
    tmux.enable = true;
    starship.enable = true;
  };

  # Self-hosted GitHub Actions runners are declared in a private file kept
  # OUTSIDE this public repo, so the repo URLs/labels stay private. Copy
  # home-manager/hp-prodesk-runners.nix.example to
  #   ~/.config/nix-config/hp-prodesk-runners.nix
  # (a plain attrset, one entry per repo) and switch with --impure:
  #   home-manager switch --flake .#linhnguyen@hp-prodesk --impure
  # Reading a path outside the flake needs --impure; without the file this is
  # an empty set and no runners are created.
  githubRunners =
    let
      runnersFile = "${config.home.homeDirectory}/.config/nix-config/hp-prodesk-runners.nix";
    in
    lib.optionalAttrs (builtins.pathExists runnersFile) (import runnersFile);

  # NFS share from Synology DS223 (192.168.1.100:/volume1/media)
  # Mounted at system level via /etc/fstab — see docs/nfs-setup.md
  jellyfinOpts.mediaPath = "/mnt/nas/media";

  fonts.fontconfig.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
