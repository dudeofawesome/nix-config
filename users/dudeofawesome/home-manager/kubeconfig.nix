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

      "users/dudeofawesome/kubeconfig/clusters/monongahela/server" = { };
      "users/dudeofawesome/kubeconfig/clusters/monongahela/certificate-authority-data" = { };

      "users/dudeofawesome/kubeconfig/clusters/doa-cluster/server" = { };
      "users/dudeofawesome/kubeconfig/clusters/doa-cluster/certificate-authority-data" = { };
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
        };
      };
    };
  };
}
