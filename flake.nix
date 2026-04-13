{
  description = "ixai home manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    try.url = "github:tobi/try";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
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
    };
}
