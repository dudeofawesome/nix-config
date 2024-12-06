{ ... }: {
  imports = [
    ./vscode.nix
    ./vim
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
}
