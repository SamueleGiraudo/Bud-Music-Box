# Bud Music Box
A tool to generate random music from short patterns using operads, colored operads, and bud
generating systems.

Copyright (C) 2019--2020 Samuele Giraudo - `samuele.giraudo@u-pem.fr` -
[https://igm.univ-mlv.fr/~giraudo/]


## Versions
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
1. [Temporization](Examples/Temporization.bmb)
1. [Rhythmization](Examples/Rhythmization.bmb)
1. [Harmonization](Examples/Harmonization.bmb)
1. [Arpeggiation](Examples/Arpeggiation.bmb)
1. [Mobiusation](Examples/Mobiusation.bmb)


### Complete examples
+ An [example](Examples/CompleteHir1.bmb) on the Hirajoshi scale, played on kotos.
+ An [example](Examples/CompleteHir2.bmb) on the Hirajoshi scale, played on voices.
+ An [example](Examples/CompleteMaj1.bmb) on the major natural scale.
+ An [example](Examples/CompleteHar1.bmb) on the minor harmonic scale.
+ An [example](Examples/CompletePen1.bmb) on the minor pentatonic scale.


## Building
The following instructions hold for Linux systems like Debian or Archlinux, after 2019.

1. Clone the repository somewhere by running
`git clone https://github.com/SamueleGiraudo/Bud-Music-Box.git`.

2. Install all dependencies (see the section below).

3. Build the project by running `chmod +x Compil` and then `./Compil`.

This creates an executable `bmb`.


## Dependencies
The following programs are needed and they are available for most of the Linux systems like
Debian or Archlinux, after 2019.

+ `ocaml` (Version `>= 4.06.0`.)
+ `ocamlbuild`
+ `ocaml-findlib`
+ `opam`
+ `extlib` (Available by `opam install extlib`. Do not forget to run `opam init` first.)
+ `abcmidi`
+ `abcm2ps`
+ `timidity`
+ `rlwrap` (Optional.)


## User guide
This [page](Help.md) contains the description of the Bud Music Box instruction set and
language.

Files containing such instructions must have `bmb` as extension. Given such a file
`Program.bmb`, the command

`./bmb -f Program.bmb`

executes line by line each of its instructions.


## Theoretical aspects
An operad is an algebraic structure wherein elements are operations. This program is based
upon an operad on an abstraction of polyphonic musical phrases called multi-patterns. The
set of all this object is endowed with the structure of an operad allowing us to perform
computations on musical phrases. The main idea is that one can, from a set of small musical
phrases, generate randomly a new musical phrase by computing some random compositions of
these patterns.


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
      Discrete Math.,
      342, 6, 1624--1657, 2019.

+ About the operad of patterns:
    + S. Giraudo.
      Generation of musical pattern through operads.
      Preprint, 2020.

    + S. Giraudo.
      The music box operad: random generation of musical phrases from patterns.
      Work in progress, 2020.

