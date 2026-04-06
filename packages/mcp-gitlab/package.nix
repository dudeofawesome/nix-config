{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  ...
}:

buildNpmPackage (finalAttrs: {
  pname = "mcp-gitlab";
  version = "2.0.35";

  src = fetchFromGitHub {
    owner = "zereight";
    repo = "gitlab-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-p/XfTJQAoZ+rSrUV5pBsXEj3QgwPaDwW4CAudevrf+Y=";
  };

  npmDepsHash = "sha256-JBgGnvtTxLjfxHfsvwQIfVAMMFcSANYRAWKiKa3ApvI=";

  nativeBuildInputs = [ nodejs ];

  npmBuildScript = "build";

  postInstall = ''
    ln -s "$out/bin/@zereight/mcp-gitlab" "$out/bin/mcp-gitlab"
  '';

  meta = {
    description = "GitLab MCP server";
    homepage = "https://github.com/zereight/gitlab-mcp";
    license = lib.licenses.mit;
    mainProgram = "mcp-gitlab";
  };
})
