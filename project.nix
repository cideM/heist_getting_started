{ mkDerivation, base, blaze-builder, heist, lib, map-syntax
, microlens-platform, text, transformers
}:
mkDerivation {
  pname = "haskell-starter";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base blaze-builder heist map-syntax microlens-platform text
    transformers
  ];
  license = "unknown";
  mainProgram = "haskell-starter";
}
