{ config, ... }:
{
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
}
