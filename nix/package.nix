{
  lib,
  stdenv,
  hareHook,
  writableTmpDirAsHomeHook,
  just,
}:

stdenv.mkDerivation {
  pname = "minicore";
  version = "0.1.0";

  src = lib.cleanSource ../.;

  nativeBuildInputs = [
    hareHook
    writableTmpDirAsHomeHook
    just
  ];

  buildPhase = ''
    runHook preBuild
    just build # this has only release mode
    # just build-o2 # this has stripping + release mode
    # just build-o3 # this has aggressive stripping + release mode
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 result/minicore "$out/bin/minicore"
    runHook postInstall
  '';

  meta = {
    description = "Busybox implementation in harelang";
    mainProgram = "minicore";
    platforms = lib.platforms.linux;
  };
}
