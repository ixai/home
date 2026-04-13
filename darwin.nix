{
  config,
  pkgs,
  inputs,
  system,
  ...
}:

let
  inherit (inputs) try;
in
{
  home.username = "ixai";
  home.homeDirectory = "/Users/ixai";

  programs.zsh = {
    initContent = ''
      eval "$(/opt/homebrew/bin/brew shellenv zsh)"
    '';
  };
}
