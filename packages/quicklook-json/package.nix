{
  lib,
  stdenv,
  fetchurl,
  unzip,
  ...
}:

stdenv.mkDerivation {
  pname = "quicklook-json";
  version = "1.0";

  src = fetchurl {
    url = "http://www.sagtau.com/media/QuickLookJSON.qlgenerator.zip";
    hash = "sha256-QpRV1kPS0wznETKjVacpk8JJdSj6WhKJMNja3WXbue8=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Library/QuickLook"
    mv QuickLookJSON.qlgenerator "$out/Library/QuickLook/"

    runHook postInstall
  '';

  meta = {
    description = "Quick Look plugin for JSON files";
    homepage = "http://www.sagtau.com/quicklookjson.html";
    license = lib.licenses.free;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
