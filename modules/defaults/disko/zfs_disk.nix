{ device, pool ? "storage" }: {
  type = "disk";
  inherit device;
  content = {
    type = "gpt";
    partitions = {
      zfs = {
        size = "100%";
        content = {
          type = "zfs";
          inherit pool;
        };
      };
    };
  };
}
