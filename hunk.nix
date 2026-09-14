{ pkgs, ... }:

{
  home.packages = [ pkgs.hunk ];

  xdg.configFile."hunk/config.toml".text = ''
    theme = "catppuccin-frappe"
  '';
}
