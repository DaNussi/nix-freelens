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
            version = "1.9.0";
            pname = "freelens";


            srcData = if pkgs.system == "aarch64-linux" then {
              url = "https://github.com/freelensapp/freelens/releases/download/v${version}/Freelens-${version}-linux-arm64.deb";
              sha256 = "98f12fb594c7bb1cd7eee900603acc657daaa7911d58b83e45dd8783eaac8551";
            } else if pkgs.system == "x86_64-linux" then {
              url = "https://github.com/freelensapp/freelens/releases/download/v${version}/Freelens-${version}-linux-amd64.deb";
              sha256 = "1b1588e487513eb530ab84cbd55a8bfeba6308e058bd5259c9861deccb8acda6";
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