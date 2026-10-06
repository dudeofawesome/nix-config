{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  python3,
  _7zz,
  zulu8,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "poweralert-console";
  version = "12.06.0069";
  archiveVersion = "12-6-0069_3";

  src = fetchurl {
    url = "https://assets.tripplite.com/firmware/snmpwebcard-fw-${finalAttrs.archiveVersion}.zip";
    hash = "sha256-3raxgoeP9y76SYJLaRFFQ5FjqFPb3cE78wH4QcT/Ryo=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3
    _7zz
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    7zz e "$src" 'Utility/PALLauncherSetup-${finalAttrs.version}.exe'
    python ${./extract-installer.py} PALLauncherSetup-${finalAttrs.version}.exe
    7zz e launcher.msi Data1.cab
    7zz e Data1.cab pal.jar jdk7adapter.jar

    install -Dm444 pal.jar "$out/share/poweralert-console/pal.jar"
    install -Dm444 jdk7adapter.jar "$out/share/poweralert-console/jdk7adapter.jar"
    install -Dm444 ${./legacy-tls.security} "$out/share/poweralert-console/legacy-tls.security"

    makeWrapper ${lib.getExe zulu8} "$out/bin/poweralert-console" \
      --add-flags "-Djava.security.properties=$out/share/poweralert-console/legacy-tls.security" \
      --add-flags "-cp $out/share/poweralert-console/pal.jar:$out/share/poweralert-console/jdk7adapter.jar" \
      --add-flags "com.tripplite.paconsole2.controller.startup.PAL -p 3664"

    runHook postInstall
  '';

  meta = {
    description = "Legacy PowerAlert Java console for Tripp Lite SNMPWEBCARD devices";
    homepage = "https://tripplite.eaton.com/products/power-alert";
    license = lib.licenses.unfree;
    mainProgram = "poweralert-console";
    platforms = zulu8.meta.platforms;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
  };
})
