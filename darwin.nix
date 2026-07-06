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

  home.packages = [
    (pkgs.google-cloud-sdk.withExtraComponents [
      pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
  ];

  programs.btop.enable = true;
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    lspServers = {
      go = {
        args = [ "serve" ];
        command = [ "gopls" ];
        extensionToLanguage = {
          ".go" = "go";
        };
      };
    };

    context = ''
      ## Behavior & style

      - Be pragmatic, clear, and rigorous.
      - Write in a concise, actionable manner; minimal fluff.
      - Explain decisions and tradeoffs when needed.

      ## Etiquette

      - Never add yourself as a commit co-author, or identify yourself in PR descriptions.
      - Always honor PR templates from the repository you're working on; you may add sections for emphasis.
      - Always create PRs as drafts; only mark them as "ready for review" on explicit user instructions.
      - Always write comments as quotes, and prefix the messages with a 🤖 emoticon.

      ```
      🤖
      > This is an example comment.
      ```

      ## Guardrails

      - Never do destructive git operations (rebase, amend, push force, etc.) without explicit user instructions.

      ## Tooling

      - Prefer the `fd` and `rg` commands for file search.
      - Prefer the `gh` command line to interact with GitHub.
      - Prefer the `acli` command line to interact with Jira.
      - Prefer the `pup` command line to interact with DataDog.
    '';
  };

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
      . ~/.ixai/rc
      . ~/.ixai/workrc
    '';

    envExtra = ''
      . ~/.ixai/env
    '';

    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv zsh)"
    '';
  };

  programs.git = {
    enable = true;

    settings = {
      user.email = "ixai@mercari.com";
      # user.signingkey = "541E7CE6B327D35A89CEB87FF14546FABD44BF08";
      user.signingkey = "32912C5BB2BC170E56441B9DBA670BB79FB259DB";

      commit.gpgsign = true;
      gpg.program = "${pkgs.gnupg}/bin/gpg";

      url."ssh://git@github.com/".insteadOf = "https://github.com/";

      credential.helper = "/usr/local/share/gcm-core/git-credential-manager";
      credential."https://dev.azure.com".useHttpPath = true;
    };
  };

  programs.go = {
    enable = true;
    env = {
      GOPRIVATE = [
        "github.com/kouzoh"
      ];
    };
  };
}
