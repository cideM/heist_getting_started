## Getting Started

If you have Nix you can do `nix develop` followed by `cabal run`. If you don't have Nix, you can also just run `cabal run` granted that GHC is available. At the time of writing I'm using GHC 9.4.6.

## Problem

I want to create a minimal example of how to use the Heist templating system without using Snap. It should use compiled Heist.

The general idea of what the code is supposed to do is:

1. Load and precompile all templates
2. Make a fake database call outside of any splice/template/Heist functions
3. Apply the precompiled templates to data

I have no idea how to do that.

