{
  description = "boom";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    # flake-utils.lib.eachDefaultSystem
    flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        haskellPackages = pkgs.haskellPackages;
        exeOnly = b:
          with pkgs.haskell.lib;
          enableSharedExecutables (enableSharedLibraries
            (disableStaticLibraries (disableExecutableProfiling b)));
      in
      rec {
        packages.boom =
          haskellPackages.callCabal2nix "boom" ./. rec {
            # Dependency overrides go here
          };

        defaultPackage = exeOnly packages.boom;

        devShell =
          let
            scripts = pkgs.symlinkJoin {
              name = "scripts";
              paths = pkgs.lib.mapAttrsToList pkgs.writeShellScriptBin {
                ormolu-ide = ''
                  ${pkgs.ormolu}/bin/ormolu -o -XNoImportQualifiedPost -o -XOverloadedRecordDot $@
                '';
              };
            };
          in
          pkgs.mkShell {
            buildInputs = with haskellPackages; [
              haskell-language-server
              ghcid
              cabal-install
              scripts
              ormolu
            ];
            inputsFrom = [ self.defaultPackage.${system}.env ];
          };
      });
}
