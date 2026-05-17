{
  config,
  pkgs,
  inputs,
  system,
  ...
}:

let
  inherit (inputs) niri;
in
{
  home.username = "ixai";
  home.homeDirectory = "/home/ixai";

  home.sessionVariables = {
    npm_config_prefix = "$HOME/.local";
  };

  home.packages = [ niri.packages.${system}.default ];

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

  programs.git = {
    enable = true;
    settings.user.email = "ixai.lanzagorta@gmail.com";

    settings = {
      credential."https://github.com".helper = [
        "!${pkgs.gh}/bin/gh auth git-credential"
      ];
      credential."https://gist.github.com".helper = [
        "!${pkgs.gh}/bin/gh auth git-credential"
      ];
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    environmentVariables = {
      ROCR_VISIBLE_DEVICES = "1";
    };
  };
}
