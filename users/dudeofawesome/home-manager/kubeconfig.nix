{
  lib,
  config,
  machine-class,
  ...
}:
{
  config = lib.mkIf (machine-class == "pc") {
    sops.secrets = {
      "users/dudeofawesome/kubeconfig/users/dudeofawesome/client-certificate-data" = { };
      "users/dudeofawesome/kubeconfig/users/dudeofawesome/client-key-data" = { };

      "users/dudeofawesome/kubeconfig/users/lorleans@paciolan.com/token" = { };

      "users/dudeofawesome/kubeconfig/clusters/monongahela/server" = { };
      "users/dudeofawesome/kubeconfig/clusters/monongahela/certificate-authority-data" = { };

      "users/dudeofawesome/kubeconfig/clusters/pac-rancher-eks/server" = { };
    };

    programs = {
      kubeconfig = {
        enable = true;
        users = {
          dudeofawesome = {
            client-certificate-data =
              config.sops.secrets."users/dudeofawesome/kubeconfig/users/dudeofawesome/client-certificate-data".path;
            client-key-data =
              config.sops.secrets."users/dudeofawesome/kubeconfig/users/dudeofawesome/client-key-data".path;
          };
          "lorleans@paciolan.com" = {
            token = config.sops.secrets."users/dudeofawesome/kubeconfig/users/lorleans@paciolan.com/token".path;
          };
        };
        clusters = {
          monongahela = {
            server = config.sops.secrets."users/dudeofawesome/kubeconfig/clusters/monongahela/server".path;
            certificate-authority-data =
              config.sops.secrets."users/dudeofawesome/kubeconfig/clusters/monongahela/certificate-authority-data".path;
          };
          pac-rancher-eks.server =
            config.sops.secrets."users/dudeofawesome/kubeconfig/clusters/pac-rancher-eks/server".path;
        };

        contexts = {
          doa-cluster = {
            cluster = "monongahela";
            user = "dudeofawesome";
          };
          "pac/rancher-eks" = {
            cluster = "pac-rancher-eks";
            user = "lorleans@paciolan.com";
          };
        };
      };
    };
  };
}
