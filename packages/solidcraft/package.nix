{
  lib,
  stdenv,
  rustPackages_1_98,
  fetchFromGitHub,
  makeWrapper,
  wayland,
  libxkbcommon,
  libglvnd,
  vulkan-loader,
  dbus,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxrender,
  libxext,
  libxcb,
  ...
}:
let
  runtimeLibs = lib.optionals stdenv.hostPlatform.isLinux [
    wayland
    libxkbcommon
    libglvnd
    vulkan-loader
    dbus
    libx11
    libxcursor
    libxi
    libxrandr
    libxrender
    libxext
    libxcb
  ];
in
# SolidCore needs newer type inference than the default Rust 1.95 provides.
rustPackages_1_98.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "solidcraft";
  version = "0.30.1";

  src = fetchFromGitHub {
    owner = "tangency-labs";
    repo = "solidcraft";
    rev = "7a7fa9a1dba82e53cf4e10940070655b2f294f85";
    hash = "sha256-cy0aTfkkcQ0MzlCcSE1L3703FKeSk72JYTkSBohTwwI=";
  };

  cargoLock = {
    lockFile = "${finalAttrs.src}/Cargo.lock";
    outputHashes."solidcore-1.0.1" = "sha256-SziXzxkQXY29PBOG7Ct3W8dex4RUWfAEczFUakB0k50=";
  };
  cargoBuildFlags = [
    "-p"
    "solidcraft"
    "-p"
    "solidcraft-cli"
  ];
  cargoInstallFlags = finalAttrs.cargoBuildFlags;
  # Upstream's test gate requires a GPU and a wasm target.
  doCheck = false;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = runtimeLibs;

  postInstall =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      app="$out/Applications/SolidCraft.app/Contents"
      mkdir -p "$app/MacOS" "$app/Resources"
      mv "$out/bin/solidcraft" "$app/MacOS/SolidCraft"
      mv "$out/bin/solidcraft-cli" "$app/MacOS/solidcraft-cli"
      ln -s "$app/MacOS/SolidCraft" "$out/bin/solidcraft"
      ln -s "$app/MacOS/solidcraft-cli" "$out/bin/solidcraft-cli"
      cp assets/icons/app/macos/exports/Assets.car "$app/Resources/Assets.car"
      cp assets/icons/app/macos/exports/icon.icns "$app/Resources/SolidCraft.icns"
      substitute assets/platforms/macos/Info.plist.in "$app/Info.plist" \
        --replace-fail '@VERSION@' '${finalAttrs.version}' \
        --replace-fail '@SHORT_VERSION@' '${lib.head (lib.splitString "-" finalAttrs.version)}'
      printf 'APPL????' > "$app/PkgInfo"
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      install -Dm644 assets/platforms/linux/io.tangencylabs.solidcraft.desktop \
        "$out/share/applications/io.tangencylabs.solidcraft.desktop"
      install -Dm644 assets/platforms/linux/io.tangencylabs.solidcraft.mime.xml \
        "$out/share/mime/packages/io.tangencylabs.solidcraft.xml"
      for size in 16 24 32 48 64 128 256 512; do
        install -Dm644 "assets/icons/app/linux/exports/hicolor/''${size}x''${size}/apps/io.tangencylabs.solidcraft.png" \
          "$out/share/icons/hicolor/''${size}x''${size}/apps/io.tangencylabs.solidcraft.png"
      done
    '';

  postFixup =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      app="$out/Applications/SolidCraft.app"
      /usr/bin/codesign --force --sign - "$app/Contents/MacOS/solidcraft-cli"
      /usr/bin/codesign --force --sign - "$app"
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram "$out/bin/solidcraft" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}:/run/opengl-driver/lib" \
        --set-default XDG_DATA_DIRS /usr/local/share:/usr/share \
        --prefix XDG_DATA_DIRS : "$out/share:/run/opengl-driver/share"
    '';

  meta = {
    description = "Parametric 3D CAD application with a CLI and MCP server";
    homepage = "https://github.com/tangency-labs/solidcraft";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "solidcraft";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
