{
  description = "Nix setup (system-manager / home-manager)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    try.url = "github:tobi/try";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:niri-wm/niri";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      system-manager,
      nix-system-graphics,
      ...
    }@inputs:
    let
      mkHome =
        system: platform:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./common.nix
            platform
          ];
          extraSpecialArgs = { inherit inputs system; };
        };
    in
    {
      homeConfigurations = {
        "ixai@personal" = mkHome "x86_64-linux" ./linux.nix;
        "ixai@work" = mkHome "aarch64-darwin" ./darwin.nix;
      };

      systemConfigs.default = system-manager.lib.makeSystemConfig {
        modules = [
          { nix.settings.experimental-features = "nix-commands flakes"; }
          nix-system-graphics.systemModules.default
          ./system.nix
        ];
      };
    };
}
