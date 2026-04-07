{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule (finalAttrs: {
  pname = "kubernetes-mcp-server";
  version = "0.0.60";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "kubernetes-mcp-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-btFtMO0+cIJ44cHMYLUrYMpamBhuiLgxCf8gzEXYCHs=";
  };

  subPackages = [ "cmd/kubernetes-mcp-server" ];

  vendorHash = "sha256-JlbkmVa1CbfybU2554p0yuf1NsSqx3ZohZCcWpoFWgo=";

  meta = with lib; {
    description = "Model Context Protocol (MCP) server for Kubernetes and OpenShift";
    homepage = "https://github.com/containers/kubernetes-mcp-server";
    license = licenses.asl20;
    mainProgram = "kubernetes-mcp-server";
  };
})
