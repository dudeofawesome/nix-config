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
  version = "2.3.7";

  src = fetchFromGitHub {
    owner = "zereight";
    repo = "gitlab-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FIJt1IekSW7OashxyQlMMDqjPAjuAAVjbNjtddUtexE=";
  };

  npmDepsHash = "sha256-a1owNbJt9A4l3fPVvUJ59+QZk11DxvUeRh7OGCs3AFo=";

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
