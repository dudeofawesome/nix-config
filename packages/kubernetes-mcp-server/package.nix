{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  ...
}:

buildGo127Module (finalAttrs: {
  pname = "kubernetes-mcp-server";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "kubernetes-mcp-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GdOxzHS1zgJHh4EAqAj/WnjyavlBxmOIQw1tivhiCYw=";
  };

  subPackages = [ "cmd/kubernetes-mcp-server" ];

  vendorHash = "sha256-rBwmgwNfD2XbB4POOm10/oi23/t2chLMoeGeKCKwWbw=";

  meta = with lib; {
    description = "Model Context Protocol (MCP) server for Kubernetes and OpenShift";
    homepage = "https://github.com/containers/kubernetes-mcp-server";
    license = licenses.asl20;
    mainProgram = "kubernetes-mcp-server";
  };
})
