{ ... }: {
  config.programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      editor = {
        scroll-lines = 1;
        line-number = "relative";
        cursorline = true;
      };
    };
  };
}
