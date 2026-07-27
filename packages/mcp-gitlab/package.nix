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
  version = "2.1.43";

  src = fetchFromGitHub {
    owner = "zereight";
    repo = "gitlab-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0oHkIyTCLCkKH9wGHXrnEVco58yzK5nQNJHs30za3RY=";
  };

  npmDepsHash = "sha256-n8HCYN7gfyAR60HgK+VArJH1YkY8s+NC2kM248LekJA=";

  nativeBuildInputs = [ nodejs ];

  npmBuildScript = "build";

  postInstall = ''
    ln -s "$out/bin/@zereight/mcp-gitlab" "$out/bin/mcp-gitlab"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GitLab MCP server";
    homepage = "https://github.com/zereight/gitlab-mcp";
    license = lib.licenses.mit;
    mainProgram = "mcp-gitlab";
  };
})
