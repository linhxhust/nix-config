{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$kubernetes$git_status$git_branch$aws";
      continuation_prompt = "[∙](bright-black) ";
      git_status = {
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
      };
      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        symbol = " ";
        style = "purple bg:0xFCA17D";
        truncation_length = 9223372036854775807;
        truncation_symbol = "…";
        only_attached = false;
        always_show_remote = false;
        ignore_branches = [];
        disabled = false;
      };
      add_newline = false;
      line_break = {
        disabled = false;
      };
      username = {
        format = "[$user]($style) ";
        show_always = true;
        style_root = "red bg:0x9A348E";
        style_user = "yellow bg:0x9A348E";
        disabled = true;
      };
      hostname = {
        disabled = true;
        format = "[$ssh_symbol](blue dimmed)[$hostname]($style) ";
        ssh_only = false;
        style = "green dimmed";
        trim_at = ".";
      };
      localip = {
        disabled = true;
        format = "[@$localipv4]($style) ";
        ssh_only = false;
        style = "yellow";
      };
      directory = {
        disabled = false;
        fish_style_pwd_dir_length = 0;
        format = "[$path]($style)[$read_only]($read_only_style) ";
        home_symbol = "~";
        read_only_style = "red";
        repo_root_format = "[$before_root_path]($style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
        style = "cyan bg:0xDA627D";
        truncate_to_repo = true;
        truncation_length = 2;
        truncation_symbol = "…/";
        use_logical_path = true;
        use_os_path_sep = true;
      };
      kubernetes = {
        disabled = false;
        format = "[$symbol$context]($style) ";
        style = "red dimmed";
        symbol = "⛵";
      };
      aws = {
        format = "[$symbol($profile )(($region) )([$duration] )]($style) ";
        symbol = "🅰 ";
        style = "yellow";
        disabled = false;
        expiration_symbol = "X";
        force_display = false;
      };
    };
  };
  programs.fzf.enable = true;
  programs.zsh = {
    enable = true;
    envExtra = ''
      . ${pkgs.nix}/etc/profile.d/nix-daemon.sh
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "fasd" "fzf" "direnv" ];
    };

    shellAliases = {
      ll = "ls -l";
      tls = "tmux list-sessions";
      tnew = "tmux new-session -s";
      ta = "tmux attach-session -t";
      tkill = "tmux kill-session -t";
      k = "kubectl";
      kl = "kubectl logs -f";
      kd = "kubectl describe";
      kcu = "kubectl config use-context";
      uuidgen = "uuidgen | tr A-F a-f";

    };
    syntaxHighlighting.enable = true;
    history = { size = 1000000; };
    enableCompletion = true;
  };
}
