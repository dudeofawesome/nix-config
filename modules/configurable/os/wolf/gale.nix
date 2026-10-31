{ pkgs }:
let
  version = "1.23.3";
  src = pkgs.fetchurl {
    url = "https://github.com/Kesomannen/gale/releases/download/${version}/Gale_${version}_amd64.AppImage";
    hash = "sha256-0rA15KSluNd1kDU7n3RIs+9by/dmjvM15y5eRXFqwB0=";
  };
  contents = pkgs.appimageTools.extractType2 {
    pname = "gale";
    inherit version src;
  };
in
# Only portable data and Python sources go into the container. A Nix-wrapped
# executable would require the host's Nix store inside the Ubuntu container.
pkgs.runCommand "wolf-gale-${version}" { } ''
  mkdir -p $out/app $out/python/vdf
  cp -R ${contents}/. $out/app/
  cp ${pkgs.python3Packages.vdf}/${pkgs.python3.sitePackages}/vdf/*.py $out/python/vdf/
  cp ${./configure-gale.py} $out/configure-gale.py
  cp ${./45-gale.sh} $out/45-gale.sh
  cp ${./91-gale.conf} $out/91-gale.conf
''
