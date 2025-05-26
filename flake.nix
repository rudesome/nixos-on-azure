{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

  outputs = {nixpkgs, ...}: let
    username = "rudesome";
    system = "x86_64-linux";
    forAllSystems = nixpkgs.lib.genAttrs ["aarch64-darwin" "x86_64-linux"];
    pkgs = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    packages.${system} = {
      azure-image =
        (nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./configuration.nix {inherit username;})
          ];
        }).config.system.build.azureImage;
    };

    devShells = forAllSystems (system: {
      default = pkgs.${system}.mkShell {
        buildInputs = with pkgs.${system}; [
          azure-cli
          azure-storage-azcopy
          jq
          starship
        ];
        shellHook = ''
          eval "$(starship init bash)"
        '';
      };
    });
  };
}
