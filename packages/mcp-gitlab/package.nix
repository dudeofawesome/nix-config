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
  version = "2.1.46";

  src = fetchFromGitHub {
    owner = "zereight";
    repo = "gitlab-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HpGo60cnRVzbUDxjYeqE82KFVUuJp3EuRE3jQTnnVj0=";
  };

  npmDepsHash = "sha256-I0/CbaADXGjZhzpR4KhNKCIs/16L1CifIV7lKtmRmnw=";

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
