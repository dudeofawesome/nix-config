{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  nix-update-script,
  ...
}:

buildNpmPackage (finalAttrs: {
  pname = "mcp-gitlab";
  # renovate: datasource=github-releases depName=mcp-gitlab packageName=zereight/gitlab-mcp
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "zereight";
    repo = "gitlab-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Ce3Mm5Ni/2HEiSB/1/0W6WRRwUx2EFRiCGLXHVdCLRQ=";
  };

  npmDepsHash = "sha256-1UuxzoqRseTMOsKJnPiuuU2fFIJZphwxgsi2kJyOJ5A=";

  nativeBuildInputs = [ nodejs ];

  npmBuildScript = "build";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "GitLab MCP server";
    homepage = "https://github.com/zereight/gitlab-mcp";
    license = lib.licenses.mit;
    mainProgram = "mcp-gitlab";
  };
})
