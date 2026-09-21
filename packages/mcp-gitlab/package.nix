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
  version = "2.1.64";

  src = fetchFromGitHub {
    owner = "zereight";
    repo = "gitlab-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ud8NE4mhE9ro7/UUC8gaGPfe7h3RWmuzwiir+ee/pJg=";
  };

  npmDepsHash = "sha256-reQcxjiOQkzgbFDZ0+tPUQ710JnbloiFcfDe+FQ5/+Y=";

  nativeBuildInputs = [ nodejs ];

  npmBuildScript = "build";

  postInstall = ''
    ln -s "$out/bin/@zereight/mcp-gitlab" "$out/bin/mcp-gitlab"
  '';

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
