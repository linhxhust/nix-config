{ pkgs, config, ... }: {
  imports = [
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
    homeDirectory = "/Users/linhnguyen";
    stateVersion = "23.05";
    packages = with pkgs; [
      nerd-fonts.inconsolata
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      docker-client
      hadolint
      nushell
      lima
      uv
      awscli2
      terraform
      terraform-ls
      golangci-lint
      colima
      docker
      kubectl
      kubernetes-helm
      tflint
      zoxide
      eza
      krew
      inetutils
      pwgen
      tcptraceroute
      ansible
      claude-code
      vscode
      markdownlint-cli
      azure-cli
      lazygit
    ];
  };

  programs.home-manager.enable = true;

  userConf = {
    terminalFontSize = 14.0;
    gitGpgSSHSignProgram =
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    gitFolderConfigs = {
      "/Users/linhnguyen/Workspace/corporate/" =
        "/Users/linhnguyen/Workspace/corporate/.gitconfig";
    };
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
