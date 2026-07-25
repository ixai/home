{
  description = "Nix setup (system-manager / home-manager)";

  # Every third-party input pins its *own* nixpkgs in its flake.lock by default.
  # `inputs.nixpkgs.follows = "nixpkgs"` overrides that so they all share this
  # flake's top-level nixpkgs — keeping package versions in sync across
  # home-manager and system-manager.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # --- tools ---
    try.url = "github:tobi/try";
    try.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:niri-wm/niri";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # --- module systems ---
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    system-manager.url = "github:numtide/system-manager";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-system-graphics.url = "github:soupglasses/nix-system-graphics";
    nix-system-graphics.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      system-manager,
      nix-system-graphics,
      treefmt-nix,
      ...
    }@inputs:
    let
      # Per-system treefmt evaluation. `.config.build.wrapper` is the runnable
      # `treefmt` package; it also backs the `nix fmt` formatter output below.
      treefmtEval = system: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix;

      mkHome =
        system: platform:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./common.nix
            platform
          ];
          extraSpecialArgs = {
            inherit inputs system;
            treefmt = (treefmtEval system).config.build.wrapper;
          };
        };
    in
    {
      homeConfigurations = {
        "ixai@ninsun" = mkHome "x86_64-linux" ./linux.nix;
        "ixai@D6R6PWWX1F" = mkHome "aarch64-darwin" ./darwin.nix;
      };

      formatter = {
        "x86_64-linux" = (treefmtEval "x86_64-linux").config.build.wrapper;
        "aarch64-darwin" = (treefmtEval "aarch64-darwin").config.build.wrapper;
      };

      systemConfigs.default = system-manager.lib.makeSystemConfig {
        modules = [
          nix-system-graphics.systemModules.default
          ./system.nix
        ];
      };
    };
}
