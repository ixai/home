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
  '';
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

    settings = {
      attribution = {
        commit = "";
        pr = "";
        sessionUrl = false;
      };
      model = "opus";
      effortLevel = "high";
      theme = "dark-ansi";
      awaySummaryEnabled = false;
      statusLine = {
        type = "command";
        command = "${statusline}";
      };
      # The twg (Teamwork Graph) CLI installs its skills into ~/.claude/skills.
      # Jira is the only Atlassian product in use, so the main agent never
      # needs them; the typhon agent reads the twg and twg-jira SKILL.md files
      # itself. `user-invocable-only` keeps `/twg` available at the prompt.
      skillOverrides = {
        twg = "user-invocable-only";
        twg-jira = "user-invocable-only";
        twg-agentic-search = "off";
        twg-artifacts = "off";
        twg-code-review = "off";
        twg-confluence = "off";
        twg-context-discovery = "off";
        twg-engineering-work = "off";
        twg-jira-resolve-merged-work = "off";
        twg-operational-health = "off";
        twg-responsibility-routing = "off";
        twg-space-creation = "off";
        twg-status-rollups = "off";
      };
    };

    agents = {
      typhon = ./config/claude-code/agents/typhon.md;
      scribe = ./config/claude-code/agents/scribe.md;
    };

    context = ./config/agents/AGENTS.md;
  };
}
