{ config, ... }: {
  imports = [ ../user-configurations ];
  config = {
    programs.git = {
      enable = true;
      userName = "Linh Nguyen";
      userEmail = "linhxhust@gmail.com";
      aliases = {
        ci = "checkin";
        st = "status";
        br = "branch";
        co = "checkout";
        df = "diff";
        cm = "commit";
        cp = "cherry-pick";
      };
      extraConfig = {
        user.signingKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+DChIVCZ5wWSbz9/3Pi53TMOfUGYF3AkBegkP2GR+n";
        gpg = {
          format = "ssh";
          ssh.program = config.userConf.gitGpgSSHSignProgram;
        };
        core = {
          autocrlf = "input";
          editor = "nvim";
        };
        commit.gpgsign = true;
        push.default = "current";
        pull.ff = "only";
        diff = {
          algorithm = "minimal";
          compactionHeuristic = true;
          renames = true;
        };
        merge.conflictstyle = "diff3";
      };
      includes = let incConf = config.userConf.gitFolderConfigs;
      in builtins.map (ifPath: {
        condition = "gitdir:${ifPath}";
        path = incConf.${ifPath};
      }) (builtins.attrNames incConf);
    };
  };
}
