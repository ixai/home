{
  # `nix fmt` and the `treefmt` wrapper find the project root by walking up to
  # the directory containing this file.
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
}
