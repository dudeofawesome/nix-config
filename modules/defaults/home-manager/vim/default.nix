{ pkgs, ... }: {
  programs.vim = {
    enable = true;
    packageConfigurable = pkgs.vim-full;

    defaultEditor = true;
    extraConfig = builtins.readFile ./.vimrc;
    plugins = with pkgs.vimPlugins; [
      papercolor-theme
      vim-airline
      dash-vim
      nerdtree
      rainbow
      vim-prettier
      editorconfig-vim
      vim-lumen
    ];
  };
}
