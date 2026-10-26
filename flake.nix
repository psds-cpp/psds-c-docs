{
  description = "Prosoft DevSchool presentations for 'C' track of the program";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    self.submodules = true;
  };

  outputs = { self, nixpkgs, ... }: let

    system = "x86_64-linux";

    pkgs = nixpkgs.legacyPackages.${system};

    buildInputs = with pkgs; [
      texliveFull
      gnumake
      zip
    ];

  in
  {
    packages.${system}.default = pkgs.stdenvNoCC.mkDerivation {

      name = "psds-c-docs";

      src = ./.;

      nativeBuildInputs = buildInputs;

      preBuild = ''
        export HOME=$TMPDIR
        export TEXMFVAR=$TMPDIR/texmf-var
        export TEXMFCACHE=$TMPDIR/texmf-cache
        luaotfload-tool --update --force
      '';

      buildPhase = ''
        runHook preBuild
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        runHook postInstall
      '';

    };

    devShells.${system}.default = pkgs.mkShellNoCC {
      packages = buildInputs;
    };

    checks.${system}.fmt = pkgs.runCommand "check-fmt" { } ''
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${toString self}
      mkdir -p $out
    '';

  };
}
