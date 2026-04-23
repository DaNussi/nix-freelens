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
            version = "1.8.1";
            pname = "freelens";


            srcData = if pkgs.system == "aarch64-linux" then {
              url = "https://github.com/freelensapp/freelens/releases/download/v${version}/Freelens-${version}-linux-arm64.deb";
              sha256 = "394ae4ccc61fdf53e9a200c432d73d2ee7b497adee0b422c8d4138a77437123a";
            } else if pkgs.system == "x86_64-linux" then {
              url = "https://github.com/freelensapp/freelens/releases/download/v${version}/Freelens-${version}-linux-amd64.deb";
              sha256 = "4b5bc4c87dd26251479157216a0f08baf815279e0e439b697de457e86839b748";
            } else {};
            
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
          };
      };
  };
}