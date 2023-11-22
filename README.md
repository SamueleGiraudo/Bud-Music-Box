# Bud Music Box
`|3^^|3`

A tool to generate random music from short patterns using operads, colored operads, and bud
generating systems.

Copyright (C) 2019--2023 [Samuele Giraudo](https://igm.univ-mlv.fr/~giraudo/) -
`giraudo.samuele@uqam.ca` -


## Versions
+ `1.100` (2022-08-10)
    + Improvement of the syntax.
    + Empty patterns are allowed.
    + Various optimizations have been made.

+ `1.011` (2021-04-17)
    + Implementation of degree monoids: three monoids are proposed (the additive monoid,
      cyclic monoids, avec `max` monoids).
    + Big simplification of the language: the built-in constructions `transpose`,
      `temporize`, `rhythmize`, `harmonize`, and `arpeggiate` have been removed.
    + The patterns forming a multi-pattern must have the same arity.
    + Improved parsing and error messages.

+ `1.001` (2020-10-16)
    + Improved parsing and error messages.

+ `0.1111` (2020-05-20)
    + Improved efficiency of partial composition of patterns.
    + The patterns forming a multi-pattern can now have different arities.

+ `0.111` (2020-04-26)
    + New language specification.
    + Documentation improvements.
    + Add instruction `concatenate`.
    + Add instruction `repeat`.
    + Add instruction `transpose`.

+ `0.11` (2020-01-24)
    + Add instructions `binarily_composition` and `mobiusation`.
    + Language and instruction redesign.

+ `0.10` (2020-01-01)
    + Several improvements.
    + Add instructions `morphism` and `mirror`.
    + Add instructions `temporize`, `rhythmize`, `harmonize`, and `arpeggiate`.

+ `0.01` (2019-12-18)
    + Initial version.


## Quick overview and examples
This program offers a complete language allowing to represent musical patterns, to compute
over them, and to randomly generate some of them. Results can be converted to files in the
[abc format](http://abcnotation.com) and then into MIDI files.


### Main functionalities
1. [Multi-pattern creation](Examples/MultiPatternCreation.bmb)
1. [Multi-pattern operations](Examples/MultiPatternOperations.bmb)
1. [Setting the ambient scale, root, and tempo](Examples/ScaleRootTempo.bmb)
1. [Changing instruments](Examples/Sounds.bmb)
1. [Colored multi-patterns and random generation](Examples/Generation.bmb)


### Some examples
+ An [example](Examples/CompleteHir1.bmb) on the Hirajoshi scale.
+ An [example](Examples/CompleteHir2.bmb) on the Hirajoshi scale.
+ An [example](Examples/CompleteHir3.bmb) on the Hirajoshi scale.
+ An [example](Examples/CompleteMaj1.bmb) on the major natural scale.
+ An [example](Examples/CompleteHar1.bmb) on the minor harmonic scale.
+ An [example](Examples/CompletePen1.bmb) on the minor pentatonic scale.
+ An [example](Examples/CompletePen2.bmb) on the minor pentatonic scale.
+ An [example](Examples/CompletePen3.bmb) on the minor pentatonic scale.


### Other examples
+ A [Mix of patterns](Examples/Mix.bmb).
+ A [horizontal transformations](Examples/Horizontal.bmb).
+ A [vertical transformations](Examples/Vertical.bmb).
+ Some [local variations](Examples/Variation.bmb).
+ A [full piece](Examples/Composition.bmb).


## Building
The following instructions hold for Linux systems like Debian or Archlinux, after 2021.

1. Clone the repository somewhere by running
`git clone https://github.com/SamueleGiraudo/Bud-Music-Box.git`.

2. Install all dependencies (see the section below).

3. Build the project by running `make`.

This creates an executable `bmb`.


## Dependencies
The following programs are needed:

+ `pkg-config`
+ `make`
+ `ocaml` (Version `>= 5.0.0`. An inferior but not too old version may be suitable.)
+ `opam`
+ `ocamlbuild` (Available by `opam install ocamlbuild`.)
+ `ocamlfind` (Available by `opam install ocamlfind`.)
+ `extlib` (Available by `opam install extlib`.)
+ `menhir` (Available by `opam install menhir`.)
+ `abcmidi`
+ `abcm2ps`
+ `timidity`

Moreover, a proper installation of sound fonts is necessary.


## User guide
This [page](Help.md) contains the description of the Bud Music Box instruction set and
language.

Files containing such instructions must have `bmb` as extension. Given such a file
`Program.bmb`, the command

`./bmb --file Program.bmb`

executes the instructions of `Program.bmb`, sequentially from the first one to the last one.


## Miscellaneous
To get the syntax highlighting in the text editor `vim` for the Bud Music Box language, put
the file [bmb.vim](Vim/syntax/bmb.vim) at `~/.vim/syntax/bmb.vim` and the file
[bmb.vim](Vim/ftdetect/bmb.vim) at `~/.vim/fdetect/bmb.vim`.


## Theoretical aspects
An operad is an algebraic structure wherein elements are operations. This program is based
upon an operad on an abstraction of polyphonic musical phrases called multi-patterns,
forming the music box model. The set of these objects is endowed with the structure of an
operad allowing us to perform computations on musical phrases. Indeed, the operad structure
on multi-patterns makes it possible to see any multi-pattern as an operation on
multi-patterns. The main idea is that one can, from a set of small musical phrases, generate
randomly a new musical phrase by computing some random compositions of these patterns.


## Bibliography

+ About operads:
    + M. Méndez.
      Set operads in combinatorics and computer science.
      Springer, Cham, SpringerBriefs in Mathematics, xvi+129, 2015.

    + S. Giraudo.
      Nonsymmetric Operads in Combinatorics.
      Springer Nature Switzerland AG, ix+172, 2018.

+ About operads and combinatorial generation:
    + S. Giraudo.
      Colored operads, series on colored operads, and combinatorial generating systems.
      Discrete Math., 342, 6, 1624--1657, 2019.

    + S. Giraudo.
      Combinatorial operads from monoids.
      J. Algebr. Comb., 41, Issue 2, 493–538, 2015.

+ About the operad of patterns:
    + S. Giraudo.
      Generation of musical pattern through operads.
      [Journées d'informatique musicale](https://jim2020.sciencesconf.org/), 2020.

    + S. Giraudo.
      [The music box operad: random generation of musical phrases from patterns](
        https://arxiv.org/abs/2104.13040),
      Work in progress, 2022.

