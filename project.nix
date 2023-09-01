{ mkDerivation, base, blaze-builder, heist, lib, map-syntax
, microlens-platform, mtl, text
}:
mkDerivation {
  pname = "haskell-starter";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base blaze-builder heist map-syntax microlens-platform mtl text
  ];
  license = "unknown";
  mainProgram = "haskell-starter";
}
