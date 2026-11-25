{
  programs.nushell = {
    enable = true;
    shellAliases = {
      g = "git";
    };
    loadSessionVariables = true;
  };
  programs.atuin = {
    enable = true;
  };
  programs.carapace = {
    enable = true;
  };
}
