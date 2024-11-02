{ pkgs, ... }: {
  imports = [
    ./vscode.nix
  ];

  editorconfig = {
    enable = true;

    settings = {
      "*" = {
        indent_style = "space";
        indent_size = 2;
        max_line_length = 80;
        # We recommend you to keep these unchanged
        end_of_line = "lf";
        charset = "utf-8";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
      };
      "*.md" = {
        trim_trailing_whitespace = false;
        indent_size = 4;
      };
      "Makefile" = {
        indent_style = "tab";
      };
    };
  };

  programs = {
    vim = {
      enable = true;
      packageConfigurable = pkgs.vim-full;

      defaultEditor = true;
      extraConfig = builtins.readFile "${pkgs.dotfiles.dudeofawesome}/home/.vim/vimrc";
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
  };
}
