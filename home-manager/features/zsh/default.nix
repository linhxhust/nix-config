{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    settings = {
      git_status = {
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
      };
      add_newline = false;
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
    };
    syntaxHighlighting.enable = true;
    history = { size = 1000000; };
    enableCompletion = true;
  };
}
