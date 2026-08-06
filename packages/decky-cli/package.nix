{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  ...
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "decky-cli";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "cli";
    rev = finalAttrs.version;
    hash = "sha256-DCkU8ckhhNaww/6VUTUUGoDl88VaAW8SPF98vcDawj4=";
  };

  cargoHash = "sha256-1NgmL3Sj3d0AFvE7TF5a0aS/n9pRzdJILm0zTEYtaHE=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = {
    description = "CLI for developing Decky Loader plugins";
    homepage = "https://github.com/SteamDeckHomebrew/cli";
    license = lib.licenses.unfree;
    mainProgram = "decky";
    platforms = lib.platforms.unix;
  };
})
