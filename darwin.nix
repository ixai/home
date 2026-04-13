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

  home.sessionPath = [
    "/Users/ixai/Library/Application Support/JetBrains/Toolbox/scripts"
  ];

  programs.zsh = {
    shellAliases = {
      code = ''open -a "Visual Studio Code"'';
      sublime = ''open -a "Sublime Text"'';
      obsidian = ''open -a "Obsidian"'';
      flush-dns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
      dk = "kubectl --context=gke_mercari-jp-citadel-dev_asia-northeast1_citadel-2g-dev-tokyo-01";
      pk = "kubectl --context=gke_mercari-jp-citadel-prod_asia-northeast1_citadel-2g-prod-tokyo-01";
    };

    initContent = ''
      . ~/.ixai/dotixai/rc
      . ~/.ixai/dotixai/workrc
    '';

    envExtra = ''
      . ~/.ixai/dotixai/env
    '';

    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv zsh)"
    '';
  };

  programs.git = {
    enable = true;

    settings = {
      user.email = "ixai@mercari.com";
      user.signingkey = "541E7CE6B327D35A89CEB87FF14546FABD44BF08";

      commit.gpgsign = true;
      gpg.program = "/opt/homebrew/bin/gpg";

      url."ssh://git@github.com/".insteadOf = "https://github.com/";

      credential.helper = "/usr/local/share/gcm-core/git-credential-manager";
      credential."https://dev.azure.com".useHttpPath = true;
    };
  };
}
