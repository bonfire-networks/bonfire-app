{
  description = "Bonfire!";

  outputs = { self, nixpkgs }:
    let
      # taken from https://github.com/ngi-nix/project-template/blob/master/flake.nix
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
    in
    {
      overlay = final: prev: {
        bonfire = import ./nix/package.nix { pkgs = final; inherit self; };
      };
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) bonfire;
        });
      defaultPackage = forAllSystems (system: self.packages.${system}.bonfire);
      nixosModules.bonfire = import ./nix/module.nix;
      devShell = forAllSystems
        (system:
          import ./nix/shell.nix {
            pkgs = nixpkgsFor.${system};
          }
        );
    };
}
