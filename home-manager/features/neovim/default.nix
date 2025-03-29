{ pkgs, config, ... }:
let palette = config.catppuccin.flavor;
in {
  imports = [ ../user-configurations ];
  home.packages = [ pkgs.lua-language-server pkgs.nil ];
  programs.ripgrep.enable = true;
  programs.bat = { enable = true; };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  home.file.".config/nvim/init.lua".text = ''
    vim.g.catppuccin_flavour = "${palette}"
  '' + (builtins.readFile ./init.lua);
  home.file.".config/nvim/lua".source = ./lua;
}