# Bud Music Box
A tool to generate random music from short patterns using operads, colored operads, and bud
generating systems.

Copyright (C) 2019--2020 Samuele Giraudo - `samuele.giraudo@u-pem.fr` -
[https://igm.univ-mlv.fr/~giraudo/]

Versions:
+ `0.10` (2020-01-01)
    + Several improvements.
    + Add instructions `morphism` and `mirror`.
    + Add instructions `temporize`, `rhythmize`, `harmonize`, and `arpeggiate`.
+ `0.01` (2019-12-18)
    + Initial version.


## Quick overview and examples
1. [Multi-pattern creation](Examples/MultiPatternCreation.bmb)
1. [Multi-pattern composition](Examples/MultiPatternComposition.bmb)
1. [Setting the ambient scale, root, and tempo](Examples/ScaleRootTempo.bmb)
1. [Changing instruments](Examples/Sounds.bmb)
1. [Colored multi-patterns and random generation](Exampiles/Generation.bmb)


## Building
The following instructions hold for Linux systems like Debian or Archlinux, after 2019.

1. Clone the repository somewhere by running
`git clone https://github.com/SamueleGiraudo/Bud-Music-Box.git`.

2. Install all dependencies (see the section below).

3. Build the project by running `chmod +x Compil` and then `./Compil`.


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

`./Main.native -f Program.bmb`

executes line by line each of its instructions.


## Theoretical aspects

TODO


## Bibliography

TODO

+
+
+

