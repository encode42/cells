{
  description = "Package and service for Pydio Cells, a future-proof content collaboration platform";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11-small";

  outputs =
    {
      self,
      nixpkgs,
      nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;

      overlayList = [ self.overlays.default ];

      pkgsBySystem = forEachSystem (
        system:
        import nixpkgs {
          inherit system;
          overlays = overlayList;
        }
      );

    in rec {
      overlays.default = final: prev: { cells = final.callPackage ./package.nix { }; };

      packages = forEachSystem (system: {
        cells = pkgsBySystem.${system}.cells;
        default = pkgsBySystem.${system}.cells;
      });

      nixosModules = import ./nixos-modules { overlays = overlayList; };
    };
}
