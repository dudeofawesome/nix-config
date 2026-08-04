{
  lib,
  fetchgit,
  nix-update,
  rustPlatform,
  writeShellApplication,
  ...
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "overcast";
  version = "0-unstable-2023-07-10";

  src = fetchgit {
    url = "https://git.2ki.xyz/snow/overcast.git";
    rev = "0a4a4019533fd84161726381ef31af482bc893d8";
    hash = "sha256-+60O71BcGg2deGuNXJVnge54PSXQmYpX2V3N2/shjMg=";
  };

  cargoHash = "sha256-9hcbCs7gL4VYOdbZwqqqW6769OgUB63sN6hJzbRnj6s=";

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "overcast-update-script";
    runtimeInputs = [ nix-update ];
    text = ''
      nix-update --flake --system x86_64-linux overcast --version=branch
    '';
  });

  meta = {
    description = "CLI tool for managing non-Steam games in Steam";
    homepage = "https://git.2ki.xyz/snow/overcast";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "overcast";
  };
})
