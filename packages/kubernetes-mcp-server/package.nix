{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  ...
}:

buildGo127Module (finalAttrs: {
  pname = "kubernetes-mcp-server";
  version = "0.0.69";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "kubernetes-mcp-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mvWFYxI1m8awaNl7p1utQ7lLwCwVdm+6e8K/lbpBSv4=";
  };

  subPackages = [ "cmd/kubernetes-mcp-server" ];

  vendorHash = "sha256-iKexsARqV4pvYpjzd2nP79U6pzhEB7Ou5O6ET05iMQ4=";

  meta = with lib; {
    description = "Model Context Protocol (MCP) server for Kubernetes and OpenShift";
    homepage = "https://github.com/containers/kubernetes-mcp-server";
    license = licenses.asl20;
    mainProgram = "kubernetes-mcp-server";
  };
})
