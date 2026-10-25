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
  version = "2.3.9";

  src = fetchFromGitHub {
    owner = "zereight";
    repo = "gitlab-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Hiqct/sLBdQ/6qs4G4uYlEiJMy2gMPOCHXg2129NUyA=";
  };

  npmDepsHash = "sha256-KF8FjGMqVyLGdm8nugxYCyt63pJi7CPQ7MGiCpcC/oU=";

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
