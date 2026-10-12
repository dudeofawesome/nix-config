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
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "zereight";
    repo = "gitlab-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/HigvivyAFz3VzijdxueuKVTsq27o2p3TR203diQewU=";
  };

  npmDepsHash = "sha256-aXXmiPGjhdxGoMnBiPOh3HwMdysddhrOnP1B7IKv/c0=";

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
