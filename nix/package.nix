{
  lib,
  stdenv,
  hareHook,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation {
  pname = "minicore";
  version = "0.1.0";

  src = lib.cleanSource ../.;

  nativeBuildInputs = [
    hareHook
    writableTmpDirAsHomeHook
  ];

  buildPhase = ''
    runHook preBuild
    just
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 minicore "$out/bin/minicore"
    runHook postInstall
  '';

  meta = {
    description = "Busybox implementation in harelang";
    mainProgram = "minicore";
    platforms = lib.platforms.linux;
  };
}