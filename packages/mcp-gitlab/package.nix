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
  version = "2.3.15";

  src = fetchFromGitHub {
    owner = "zereight";
    repo = "gitlab-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cewbEh3GnQ8jfwpK3oaV1wMeHZ/3cXq0x8cEsjRhGFw=";
  };

  npmDepsHash = "sha256-Kcz0/fRNIALU0kHlIAi0NFMLiuaEG7z5eqlGZvIdzWc=";

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
