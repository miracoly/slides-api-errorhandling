{
  description = "Slides for nix package manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.nodejs_22
          pkgs.nodePackages.reveal-md
        ];

        shellHook = ''
          echo -e "\e[32m✔  Type 'reveal-md slides.md' for live preview (http://localhost:1948)\e[0m"
        '';
      };

      apps = {
        show = {
          type = "app";
          program = toString (pkgs.writeShellScript "show-slides" ''
            #!${pkgs.nodejs_22}/bin/node
            exec ${pkgs.nodePackages.reveal-md}/bin/reveal-md slides.md
          '');
        };

        watch = {
          type = "app";
          program = toString (pkgs.writeShellScript "watch-slides" ''
            #!${pkgs.nodejs_22}/bin/node
            exec ${pkgs.nodePackages.reveal-md}/bin/reveal-md slides.md --watch
          '');
        };
      };

      packages = rec {
        default = slides;

        slides = pkgs.stdenvNoCC.mkDerivation {
          pname = "slides-errorhandling-apis";
          version = "2025-08-12";
          src = ./.;

          nativeBuildInputs = [
            pkgs.nodejs_22
            pkgs.nodePackages.reveal-md
          ];

          buildPhase = ''
            reveal-md slides.md --static out
          '';

          installPhase = ''
            mkdir -p $out
            cp -r out/* $out/
          '';
        };
      };
    });
}
