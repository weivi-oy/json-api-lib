{compiler ? "ghc928"}: let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};

  gitignore = pkgs.nix-gitignore.gitignoreSourcePure [./.gitignore];

  myHaskellPackages = pkgs.haskell.packages.${compiler}.override {
    overrides = hself: _: {
      "json-api-lib" =
        hself.callCabal2nix
        "json-api-lib"
        (gitignore ./.)
        {};
    };
  };

  shell = myHaskellPackages.shellFor {
    packages = p: [
      p."json-api-lib"
    ];
    buildInputs = [
      myHaskellPackages.haskell-language-server
      pkgs.haskellPackages.cabal-install
      pkgs.haskellPackages.ghcid
      pkgs.haskellPackages.ormolu
      pkgs.haskellPackages.hlint
      pkgs.cabal2nix
      pkgs.niv
      pkgs.nixpkgs-fmt
      pkgs.zlib
    ];
    withHoogle = true;
  };
in {
  inherit shell;
  inherit myHaskellPackages;
  "json-api-lib" = myHaskellPackages."json-api-lib";
}
