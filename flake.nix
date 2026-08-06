{
  description = "Freelens - Free IDE for Kubernetes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }: let
    systems = [ "x86_64-linux" "aarch64-linux" ];
  in flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [];
      systems = systems;
      perSystem = { config, self', inputs', pkgs, system, ... }: let
            version = "1.10.3";
            pname = "freelens";


            srcData = if pkgs.system == "aarch64-linux" then {
              url = "https://github.com/freelensapp/freelens/releases/download/v${version}/Freelens-${version}-linux-arm64.deb";
              sha256 = "034e675e14bd90a4d933f60039ac07722a1f9db9d669548a7435db6b90a657db";
            } else if pkgs.system == "x86_64-linux" then {
              url = "https://github.com/freelensapp/freelens/releases/download/v${version}/Freelens-${version}-linux-amd64.deb";
              sha256 = "f25b7dadbc9e3a7f19b550457d913d01ecbb9c619d7dc7e84dc34995567673b4";
            } else {};

            freelens-desktop = pkgs.makeDesktopItem {
                name = "freelens";
                exec = "freelens";
                desktopName = "Freelens";
                genericName = "Freelens";
                icon = ./icon.svg;
                comment = "Free IDE for Kubernetes";
                categories = [ "Utility" ];
                terminal = false;
                keywords = [
                  "freelens"
                  "truelens"
                  "kubernetes"
                  "k8s"
                  "k3s"
                  "k9s"
                ];
            };
            
        in {
          packages.default = self'.packages.freelens;

          packages.freelens = pkgs.stdenv.mkDerivation rec {
            inherit pname version;
            
            src = pkgs.fetchurl srcData;

            nativeBuildInputs = with pkgs; [
              dpkg
              autoPatchelfHook
            ];

            buildInputs = with pkgs; [
              mesa
              gtk3
              nss
              alsa-lib
              musl
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
              platforms = systems;
            };

            desktopItems = [ freelens-desktop ];
          };
      };
  };
}