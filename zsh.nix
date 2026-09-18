{ config, lib, ... }:
{
  programs.zsh = {
    enable = true;

    defaultKeymap = "viins";
    setOptions = [ "EXTENDED_GLOB" ];
    dotDir = "${config.xdg.configHome}/zsh";
    initContent = lib.mkMerge [
      # Must run before antidote loads plugins (mkOrder 560): the
      # getantidote/use-omz plugin sources omz's check_for_upgrade.sh as soon
      # as it loads, and topgrade already keeps everything updated.
      (lib.mkOrder 500 ''
        export DISABLE_AUTO_UPDATE=true
      '')
      ''
        unsetopt beep
        zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
        eval "$(try init ~/src/tries)"

        wt() {
          local name="$1" wt_path

          wt_path=$(git worktree list --porcelain 2>/dev/null | awk -v name="$name" '
            $1 == "worktree" { path = $2; if (name == "") { print path; exit } }
            $1 == "branch" && name != "" && $2 == "refs/heads/" name { print path; exit }
          ')

          if [ -z "$wt_path" ]; then
            if [ -z "$name" ]; then
              echo "wt: not in a git repository" >&2
            else
              echo "wt: no worktree checked out for branch '$name'" >&2
            fi
            return 1
          fi

          if [ -z "$name" ]; then
            cd "$wt_path" && echo "wt: moved to repository root ($wt_path)"
          else
            cd "$wt_path" && echo "wt: moved to '$name' ($wt_path)"
          fi
        }
      ''
    ];

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
