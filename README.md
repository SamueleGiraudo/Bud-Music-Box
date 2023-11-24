# Bud Music Box
`|3^^|3`

A tool to generate random music from short patterns using operads, colored operads, and bud
generating systems.

Copyright (C) 2019--2023 [Samuele Giraudo](https://igm.univ-mlv.fr/~giraudo/) -
`giraudo.samuele@uqam.ca` -


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


## Versions
Here is the [changelog](Versions.md) of the different versions.


## Installation
The following instructions hold for Linux systems like Debian or Archlinux, after 2021.


### Dependencies
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


### Building
Here are the required steps to build the interpreter `Bud Music Box`:

1. Clone the repository somewhere by running
`git clone https://github.com/SamueleGiraudo/Bud-Music-Box.git`.

2. Install all dependencies (see the section below).

3. Build the project by running `make`.

This creates an executable `bmb`. The following sections explain how to use it.


## User guide
This [page](Help.md) contains the description of the Bud Music Box instruction set and
language.

Files containing such instructions must have `.bmb` as extension. Given such a file
`Program.bmb`, the command

`./bmb --file Program.bmb`

executes the instructions of `Program.bmb`, sequentially from the first one to the last one.


## Miscellaneous
To get the syntax highlighting in the text editor `vim` for the Bud Music Box language, put
the file [bmb.vim](Vim/syntax/bmb.vim) at `~/.vim/syntax/bmb.vim` and the file
[bmb.vim](Vim/ftdetect/bmb.vim) at `~/.vim/fdetect/bmb.vim`.


## Theoretical aspects
An operad is an algebraic structure wherein elements are operations. This generative method
is based upon an abstraction of polyphonic musical phrases called multi-patterns, forming
the music box model. The set of these objects is endowed with the structure of an operad
allowing us to perform computations on musical phrases. Indeed, the operad structure on
multi-patterns makes it possible to see any multi-pattern as an operation on multi-patterns.
The main idea is that one can, from a set of small musical phrases, generate randomly a new
musical phrase by computing some random compositions of these patterns.


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

