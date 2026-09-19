{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

    enableZshIntegration = true;

    settings = {
      command = ''${pkgs.zsh}/bin/zsh -c "${pkgs.tmux}/bin/tmux new-session"'';
      cursor-style = "block";
      fullscreen = true;
      keybind = "shift+enter=text:\\n";
      mouse-hide-while-typing = true;
      shell-integration = "zsh";
      theme = "Catppuccin Frappe";
    };
  };
}
