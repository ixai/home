{
  inputs,
  system,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.packages.${system}.claude-code;
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

    context = ./config/agents/AGENTS.md;
  };
}
