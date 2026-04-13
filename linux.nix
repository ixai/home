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
  home.homeDirectory = "/home/ixai";

  programs.zsh = {
    initContent = ''
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
    '';

    profileExtra = ''
      if uwsm check may-start && uwsm select; then
          exec uwsm start default
      fi
    '';
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
