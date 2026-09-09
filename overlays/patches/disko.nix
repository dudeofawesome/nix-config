{
  lib,
  final,
  prev,
}:
{
  disko = prev.disko.overrideAttrs (old: {
    # ...
    patches = (old.patches or [ ]) ++ [
      # https://github.com/nix-community/disko/pull/1265
      #   fixes bcachefs encrypted volume unlock
      (final.fetchpatch {
        name = "whatever-name-you-want.patch";
        url = "https://github.com/nix-community/disko/pull/1265/commits/e2bc980116461435788623b7493ccab4fe49e803.patch";
        hash = lib.fakeHash;
      })
      # https://github.com/nix-community/disko/pull/1270
      #   fixes bcachefs extraFormatArgs
      # (final.fetchpatch {
      #   name = "whatever-name-you-want.patch";
      #   url = "https://github.com/nix-community/disko/pull/1270/commits/1ae020fe7cee881b76e7c69b63b6e0775b1235d6.patch";
      #   hash = lib.fakeHash;
      # })
    ];
  });
}
