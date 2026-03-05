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

      "users/dudeofawesome/kubeconfig/users/doa-cluster-admin/client-certificate-data" = { };
      "users/dudeofawesome/kubeconfig/users/doa-cluster-admin/client-key-data" = { };

      "users/dudeofawesome/kubeconfig/users/lorleans-rancher/token" = { };
      "users/dudeofawesome/kubeconfig/users/lorleans-kube1/token" = { };

      "users/dudeofawesome/kubeconfig/clusters/monongahela/server" = { };
      "users/dudeofawesome/kubeconfig/clusters/monongahela/certificate-authority-data" = { };

      "users/dudeofawesome/kubeconfig/clusters/doa-cluster/server" = { };
      "users/dudeofawesome/kubeconfig/clusters/doa-cluster/certificate-authority-data" = { };

      "users/dudeofawesome/kubeconfig/clusters/pac-rancher-eks/server" = { };
      "users/dudeofawesome/kubeconfig/clusters/pac-kube1-eks/server" = { };
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
          doa-cluster-admin = {
            client-certificate-data =
              config.sops.secrets."users/dudeofawesome/kubeconfig/users/doa-cluster-admin/client-certificate-data".path;
            client-key-data =
              config.sops.secrets."users/dudeofawesome/kubeconfig/users/doa-cluster-admin/client-key-data".path;
          };
          "lorleans-rancher" = {
            token = config.sops.secrets."users/dudeofawesome/kubeconfig/users/lorleans-rancher/token".path;
          };
          "lorleans-kube1" = {
            token = config.sops.secrets."users/dudeofawesome/kubeconfig/users/lorleans-rancher/token".path;
          };
        };
        clusters = {
          monongahela = {
            server = config.sops.secrets."users/dudeofawesome/kubeconfig/clusters/monongahela/server".path;
            certificate-authority-data =
              config.sops.secrets."users/dudeofawesome/kubeconfig/clusters/monongahela/certificate-authority-data".path;
          };
          doa = {
            server = config.sops.secrets."users/dudeofawesome/kubeconfig/clusters/doa-cluster/server".path;
            certificate-authority-data =
              config.sops.secrets."users/dudeofawesome/kubeconfig/clusters/doa-cluster/certificate-authority-data".path;
          };
          pac-rancher.server =
            config.sops.secrets."users/dudeofawesome/kubeconfig/clusters/pac-rancher-eks/server".path;
          pac-kube1.server =
            config.sops.secrets."users/dudeofawesome/kubeconfig/clusters/pac-kube1-eks/server".path;
        };

        contexts = {
          doa = {
            cluster = "doa";
            user = "dudeofawesome";
          };
          doa-admin = {
            cluster = "doa";
            user = "doa-cluster-admin";
          };
          monongahela = {
            cluster = "monongahela";
            user = "dudeofawesome";
          };
          "pac/rancher" = {
            cluster = "pac-rancher";
            user = "lorleans-rancher";
          };
          "pac/kube1" = {
            cluster = "pac-kube1";
            user = "lorleans-kube1";
          };
        };
      };
    };
  };
}
