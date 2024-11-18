{ pkgs, lib, config, ... }: {
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin.defaults."com.apple.FileMerge" = {
      CompressWhitespace = true;
    };
  };
}
