{
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

    context = ./config/agents/AGENTS.md;
  };
}
