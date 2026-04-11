{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    darwinConfigurations = {
      Majula = inputs.nix-darwin.lib.darwinSystem {
        modules = [ ./hosts/home ];
      };

      K1QJWD679P = inputs.nix-darwin.lib.darwinSystem {
        modules = [ ./hosts/work ];
      };
    };
    formatter.aarch64-darwin = inputs.nixpkgs.legacyPackages.aarch64-darwin.alejandra;
  };
}
