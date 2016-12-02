## <img src="https://rawgit.com/alanz/HaRe/master/HaReLogo.svg" width="40" height="30" /> HaRe : The Haskell Refactorer

Home is now https://github.com/RefactoringTools/HaRe

HaRe can rename symbols, lift definitions, convert equivalent Haskell
constructs like ifs and cases and more while preserving program
semantics, types and correctly handling indentation. Only HaRe can
execute identity transformation!

[![Available on Hackage][badge-hackage]][hackage]
[![License BSD3][badge-license]][license]
[![Build Status][badge-travis]][travis]
[![Stackage LTS](http://stackage.org/package/HaRe/badge/lts)](http://stackage.org/lts/package/HaRe)
[![Stackage Nightly](http://stackage.org/package/HaRe/badge/nightly)](http://stackage.org/nightly/package/HaRe)

[badge-travis]: https://travis-ci.org/RefactoringTools/HaRe.png?branch=master
[travis]: https://travis-ci.org/RefactoringTools/HaRe
[badge-hackage]: https://img.shields.io/hackage/v/HaRe.svg?dummy
[hackage]: https://hackage.haskell.org/package/HaRe
[badge-license]: https://img.shields.io/badge/license-BSD3-green.svg?dummy
[license]: https://github.com/RefactoringTools/HaRe/blob/master/LICENSE

Note:

  * GHC versions up to 7.6.3 are supported via HaRe version 0.7.2.8
  * GHC version 7.8.x is NOT supported, and never will be
  * GHC version 7.10.2 and up is supported for HaRe >= 0.8.0.0

### Limitations

HaRe will only work for projects using GHC 7.10.2 for compilation. Compiling
HaRe with 7.10.2 and then using it against projects using an earlier compiler
will not work, as HaRe needs to be able to invoke GHC to the type checker stage
on the project using GHC 7.10.2.

See https://github.com/DanielG/ghc-mod/issues/615

### Getting Started

    cabal install HaRe
    stack install HaRe --resolver=lts-4.0

Check that it works from the command line

    $ ghc-hare --version
    0.8.x.y

Running the bare command lists available refactorings and their parameters

#### Emacs integration

Currently only emacs integration is offered. Add the following to your
~/.emacs using the load-path entry that matches the installation on
your machine.

    (add-to-load-path "~/.cabal/share/x86_64-linux-ghc-7.10.2/HaRe-0.8.2.0/elisp")
    (require 'hare)
    (autoload 'hare-init "hare" nil t)

Add an intializer hook to the ghc-mode command

    (add-hook 'haskell-mode-hook (lambda () (ghc-init) (hare-init)))

Alternatively, if using haskell-mode, and initializing via a function

    ;; Haskell main editing mode key bindings.
    (defun haskell-hook ()

      ;(lambda nil (ghc-init))
      (ghc-init)
      (hare-init)
      ...
    )

If this is done correctly, there should be an additional `Refactorer`
menu entry when opening a haskell file. The refactorings can be
initiated via the menu, or using the keyboard shortcuts displayed in
the menu.

The installation can be fine-tuned using

    M-x customize-variable

on

    hare-search-paths
    ghc-hare-command


Each refactoring will first ask for any information it requires, e.g.
a new name if renaming, and then attempt the refactoring. If any
precondition is not met this will be reported and the refactoring will
abort.

If it succeeds, you will be given the option to look at an ediff
session to see what changes would be made, and each file can be
individually accepted or declined.

If the refactoring is commited, the original file is renamed to have a
suffix containing the current timestamp.

E.g., after renaming in Foo.hs, there will be two files

    Foo.hs
    Foo.hs.2013-08-22T19:32:31+0200

This allows a sequence of refactorings to be undone manually if
required. In theory.

#### VIM integration

See https://github.com/glittershark/vim-hare

### Development & Support

Join in at `#haskell-refactorer` on freenode.

Note: (2015-10-04) HaRe cannot be tested using stack. It can be built, but the tests will
fail, as HaRe makes use of ghc-mod as a library and the interaction between
stack, ghc-mod and cabal-helper does not work for the tests.

#### Running test suite

To run the test suite do:

    ./configure.sh
    cabal test

The `configure.sh` script simply makes sure that all the cabal projects used in
the tests are also configured.

See <http://hspec.github.io/> for details on hspec

see <https://travis-ci.org/#alanz/HaRe> for continuous build results

### Resources

  * [GHC chapter](http://aosabook.org/en/ghc.html) of
    [AOSA](http://aosabook.org "Architecture of Open Source
    Applications") (if only for the diagram of GHC phases and data structures)
  * [GHC 7.6.3 API docs](http://www.haskell.org/ghc/docs/7.6.3/html/libraries/ghc-7.6.3/GHC.html)
  * [GHC 7.4.2 API docs](http://www.haskell.org/ghc/docs/7.4.2/html/libraries/ghc-7.4.2/GHC.html)
  * [Monoids: Theme and Variations](http://www.cis.upenn.edu/~byorgey/pub/monoid-pearl.pdf) 
    The background to how the dual tree data structure used for token
    output works

### Coding style

Contributors: please try to follow https://github.com/tibbe/haskell-style-guide
Note:A consistent coding layout style is more important than what specific on is used.

### Contributors

 * Alan Zimmerman
 * Christopher Brown
 * Francisco Soares
 * Gracjan Polak
 * Harald Jagenteufel
 * Huiqing Li
 * Matthew Pickering
 * Simon Thompson
 * Stephen Adams

Please put a pull request for this list if you are missing.

### Logo

<img src="https://rawgithub.com/alanz/HaRe/master/HaReLogo.svg"
width="400" height="300" />

The logo was designed by Christi du Toit,
<https://www.behance.net/christidutoit>

