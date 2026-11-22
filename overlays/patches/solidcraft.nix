{
  lib,
  pkgs,
  package,
}:
if pkgs.stdenv.hostPlatform.isDarwin then
  package.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      app="$out/Applications/SolidCraft.app/Contents"
      mkdir -p "$app/MacOS" "$app/Resources"
      mv "$out/bin/solidcraft" "$app/MacOS/SolidCraft"
      mv "$out/bin/solidcraft-cli" "$app/MacOS/solidcraft-cli"
      ln -s "$app/MacOS/SolidCraft" "$out/bin/solidcraft"
      ln -s "$app/MacOS/solidcraft-cli" "$out/bin/solidcraft-cli"
      cp assets/icons/app/macos/exports/Assets.car "$app/Resources/Assets.car"
      cp assets/icons/app/macos/exports/icon.icns "$app/Resources/SolidCraft.icns"
      substitute assets/platforms/macos/Info.plist.in "$app/Info.plist" \
        --replace-fail '@VERSION@' '${old.version}' \
        --replace-fail '@SHORT_VERSION@' '${lib.head (lib.splitString "-" old.version)}'
      printf 'APPL????' > "$app/PkgInfo"
    '';

    postFixup = (old.postFixup or "") + ''
      app="$out/Applications/SolidCraft.app"
      /usr/bin/codesign --force --sign - "$app/Contents/MacOS/solidcraft-cli"
      /usr/bin/codesign --force --sign - "$app"
    '';
  })
else
  package
