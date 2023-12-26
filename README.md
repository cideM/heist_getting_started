# Trying (and Failing) to Use Heist

This repository was created to accompany [this short series of blog posts](https://www.fbrs.io/tags/heist-journal/).

## Getting Started

If you have Nix you can do `nix develop` followed by `cabal run`. If you don't have Nix, you can also just run `cabal run` granted that GHC is available. At the time of writing I'm using GHC 9.4.6.

## Problem

I want to create a minimal example of how to use the Heist templating system without using Snap. It should use compiled Heist.

The general idea of what the code is supposed to do is:

1. Load and precompile all templates
2. Make a fake database call outside of any splice/template/Heist functions
3. Apply the precompiled templates to data

It seems to me that Heist really does not want you to fetch data in any other way than through runtime splices that access your application monad. If you look at `Main.hs` and focus on the commented out lines you can hopefully see where I'm stuck and why this doesn't look like it's possible with Heist.

I have two templates, that have the `<foo />` tag/splice in common, but also each have one other piece of data. In `Main.hs`, I'd like to be able to render either of the two views with exactly the data it needs. I do not want `mainSplices` to become an amalgamation of all the types required by both views. I don't want to have any (fake) database calls in code that mentions splices (or any other Heist related code)
