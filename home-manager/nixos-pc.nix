{ pkgs, config, lib, ... }: {
  imports = [
    ./features/1password
    ./features/alacritty
    ./features/git
    ./features/tmux
    ./features/zsh
    ./features/neovim
    ./features/go
    ./features/nushell
    ./features/user-configurations
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
      docker-client
      hadolint
      uv
      awscli2
      terraform
      terraform-ls
      golangci-lint
      gopls
      docker
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
    ];
  };

  programs.home-manager.enable = true;

  programs.go.env.GOPATH = lib.mkForce "/home/linhnguyen/tools/go";

  userConf = {
    terminalFontSize = 12.0;
    gitFolderConfigs = { };
    shellProgram = "${pkgs.zsh}/bin/zsh";
  };

  tmuxOpts.shell = config.userConf.shellProgram;

  catppuccin = {
    flavor = "frappe";
    tmux.enable = true;
    starship.enable = true;
    alacritty.enable = true;
  };

  fonts.fontconfig.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
