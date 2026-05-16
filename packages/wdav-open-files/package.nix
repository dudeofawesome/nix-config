{
  lib,
  writeShellApplication,
  gawk,
  less,
  lsof,
  ...
}:

writeShellApplication {
  name = "wdav-open-files";

  runtimeInputs = [
    gawk
    less
    lsof
  ];

  text = builtins.readFile ./wdav-open-files.sh;

  meta = with lib; {
    description = "Live filtered open-file viewer for Microsoft Defender wdavdaemon processes";
    mainProgram = "wdav-open-files";
    platforms = platforms.darwin;
  };
}
