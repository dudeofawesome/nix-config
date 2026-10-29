{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  ...
}:

buildGo127Module (finalAttrs: {
  pname = "kubernetes-mcp-server";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "kubernetes-mcp-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Rk6VqM2+YSYpHD9uwZwYzYpustErQfVojlNmYnWHifY=";
  };

  subPackages = [ "cmd/kubernetes-mcp-server" ];

  vendorHash = "sha256-ljyTvVY1cG3tHeoyOhNyl+vZWqgfqs+rIHQiKAAFnlk=";

  meta = with lib; {
    description = "Model Context Protocol (MCP) server for Kubernetes and OpenShift";
    homepage = "https://github.com/containers/kubernetes-mcp-server";
    license = licenses.asl20;
    mainProgram = "kubernetes-mcp-server";
  };
})
