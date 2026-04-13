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
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.curl
    pkgs.ruby
    pkgs.nixfmt-tree
  ]
  ++ [ try.packages.${system}.default ];

  home.file = { };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";

    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";

    ANSIBLE_NOCOWS = "1";
    HOMEBREW_NO_ANALYTICS = "1";
    ZSH_DISABLE_COMPFIX = "1";
    npm_config_prefix = "$HOME/.local";
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.fzf.enable = true;
  programs.home-manager.enable = true;
  programs.neovim.enable = true;
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  xdg.enable = true;

  programs.zsh = {
    enable = true;

    defaultKeymap = "viins";
    setOptions = [ "EXTENDED_GLOB" ];
    dotDir = "${config.xdg.configHome}/zsh";
    initContent = ''
      unsetopt beep
      zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
      eval "$(try init ~/src/tries)"
    '';

    history = {
      path = "$ZDOTDIR/.zhistory";
      size = 10000;
      save = 20000;
    };

    antidote = {
      enable = true;
      plugins = [
        ''
          getantidote/use-omz
          ohmyzsh/ohmyzsh path:lib
          ohmyzsh/ohmyzsh path:plugins/git
          olets/zsh-abbr
          olets/zsh-autosuggestions-abbreviations-strategy
          zsh-users/zsh-autosuggestions
        ''
      ];
    };

    shellAliases = {
      docker-rmall-containers = "docker rm $(docker ps -a -q)";
      docker-rmall-images = "docker rmi -f $(docker images -q)";
      docker-stopall = "docker stop $(docker ps -a -q)";
      vim = "nvim";
    };
  };

  programs.git = {
    enable = true;
    settings.user.name = "Ixai Lanzagorta";
    settings.user.email = "ixai.lanzagorta@gmail.com";
  };
}
