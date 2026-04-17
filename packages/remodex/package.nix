{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  ...
}:

buildNpmPackage (finalAttrs: {
  pname = "remodex";
  version = "1.3.8";

  src = fetchFromGitHub {
    owner = "Emanuele-web04";
    repo = "remodex";
    rev = "773c0936e65fbbf544aff0e81b307518059e1a79";
    hash = "sha256-bnhXkMgdHt7/sxjIE4RdauxZBJiQ+BFofC4ytgWr9Iw=";
  };

  sourceRoot = "${finalAttrs.src.name}/phodex-bridge";

  npmDepsHash = "sha256-3cwCUNpaSJHw86amb4Iul6kK14N+KGesga+vycOUy+8=";

  nativeBuildInputs = [
    makeWrapper
    nodejs
  ];

  dontNpmBuild = true;

  # The upstream postinstall script bootstraps Codex CLI state and should not
  # run as part of a pure Nix package build.
  npmPackFlags = [ "--ignore-scripts" ];

  postInstall = ''
    wrapProgram "$out/bin/remodex" \
      --set REMODEX_RELAY wss://api.phodex.app/relay
  '';

  meta = {
    description = "Remote Control for Codex";
    homepage = "https://github.com/Emanuele-web04/remodex";
    license = lib.licenses.isc;
    mainProgram = "remodex";
  };
})
