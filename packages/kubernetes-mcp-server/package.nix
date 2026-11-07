{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  ...
}:

buildGo127Module (finalAttrs: {
  pname = "kubernetes-mcp-server";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "kubernetes-mcp-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7BoixYxAhC9/rv+L1QRGdtqoYNUxyuAsWwbaSpqzoFY=";
  };

  subPackages = [ "cmd/kubernetes-mcp-server" ];

  vendorHash = "sha256-B8Mb0nyflZwQK1UxOlPwTxX2FjwVMM5RiAPJughaOWw=";

  meta = with lib; {
    description = "Model Context Protocol (MCP) server for Kubernetes and OpenShift";
    homepage = "https://github.com/containers/kubernetes-mcp-server";
    license = licenses.asl20;
    mainProgram = "kubernetes-mcp-server";
  };
})
