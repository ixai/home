{
  inputs,
  system,
  ...
}:
{
  programs.pi-coding-agent = {
    enable = true;
    package = inputs.llm-agents.packages.${system}.pi;
    context = ./config/agents/AGENTS.md;
  };
}
