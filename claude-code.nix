{
  config,
  pkgs,
  inputs,
  system,
  ...
}:
let
  statusline = pkgs.writeShellScript "claude-statusline" ''
    dir=$(${pkgs.jq}/bin/jq --raw-output '.workspace.current_dir')
    starship=${config.programs.starship.package}/bin/starship
    # An empty STARSHIP_SHELL makes starship emit plain ANSI escapes instead of
    # zsh %{...%} wrappers, which Claude Code would print literally.
    export STARSHIP_SHELL=
    "$starship" module directory --path "$dir"
    "$starship" module git_branch --path "$dir"
    "$starship" module git_status --path "$dir"
  '';

  # Claude Code writes to its settings and agents (`/config`, `/agents`,
  # permission grants), so these link to the working copy of this repository,
  # not to a read-only store path. Claude's changes then show up in `git diff`.
  repo = "${config.xdg.configHome}/home-manager";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
{
  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.packages.${system}.claude-code;
    enableMcpIntegration = true;
    lspServers = {
      go = {
        args = [ "serve" ];
        command = "gopls";
        extensionToLanguage = {
          ".go" = "go";
        };
      };
    };

    context = ./config/agents/AGENTS.md;
  };

  # settings.json disables most twg (Teamwork Graph) skills: Jira is the only
  # Atlassian product in use, and the typhon agent reads the twg and twg-jira
  # SKILL.md files itself. `user-invocable-only` keeps `/twg` at the prompt.
  home.file = {
    ".claude/settings.json".source = link "config/claude-code/settings.json";
    ".claude/agents".source = link "config/claude-code/agents";
    ".claude/scripts/statusline.sh".source = statusline;
  };
}
