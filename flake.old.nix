{
  description = "Freelens - Free IDE for Kubernetes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [];
      systems = [ "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.default = self'.packages.freelens;

        packages.freelens = pkgs.stdenv.mkDerivation rec {
          pname = "freelens";
          version = "1.8.1";
          
          src = pkgs.fetchurl {
            url = "https://github.com/freelensapp/freelens/releases/download/v${version}/Freelens-${version}-linux-amd64.deb";
            sha256 = "4b5bc4c87dd26251479157216a0f08baf815279e0e439b697de457e86839b748";
          };

          nativeBuildInputs = with pkgs; [
            dpkg
            autoPatchelfHook
          ];

          buildInputs = with pkgs; [
            mesa
            gtk3
            nss
            alsa-lib
          ];

          unpackPhase = "true";

          installPhase = ''
            mkdir -p $out/bin
            dpkg -x $src $out
            ln -s $out/opt/Freelens/freelens $out/bin/freelens
          '';

          meta = with pkgs.lib; {
            description = "Freelens - Free IDE for Kubernetes";
            homepage = "https://freelens.app";
            license = licenses.mit;
            maintainers = [];
            platforms = [ "x86_64-linux" ];
          };
        };
      };
    };
}