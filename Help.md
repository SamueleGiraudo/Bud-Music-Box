# Bud Music Box language instruction set
This page describes all the instructions of the Bud Music Box language.


## General conventions
Each single instruction fits on one line. All characters following a `#` in a given line are
ignored and can therefore be treated as comments.

Identifiers are strings made of symbols in `a`-`z`, `A`-`Z`, `0`-`9`, or `_`.


## Syntax for multi-patterns
A multi-pattern is specified by the sequence of its atoms, that are degrees (expressed by
signed decimal integers) or rests (expressed by `*`). The multiple voices of a multi-pattern
are separated by a `;`.

For instance,
```
1 -1 * * 2 * 4 ; 0 0 * 1 * -3 0 ; * * 2 * 2 2 * ; * 0 * 0 * * 0
```
is a string specifying a $4$-multi-pattern. This multi-pattern has arity $3$ because $3$
is the minimal number of beats among all the four voices. The length of this multi-pattern
is $7$ since each voice has seven atom, where an atom is either a beat or a rest. Therefore,
this multi-pattern lasts $7$ amounts of time.


## Instruction set

### Control instructions

#### Help
`help`

+ Prints the help.


#### Quit
`quit`

+ Quits the application.


#### Display information
`show`

+ Prints the current internal data (scale, tempo, patterns, _etc._).


#### Write the associated files of a multi-pattern 
`write FILE_NAME PAT`

+ `FILE_NAME` is a path to a non-existing file.
+ `PAT` is the name of a multi-pattern.
+ Creates the ABC file, postscript file, and MIDI file for the musical phrase encoded by the
  multi-pattern `PAT`, with the underlying context of scale, root note, tempo, and MIDI
  sounds. The created files are obtained by adding an adequate extension to `FILE_NAME`.


#### Play a multi-pattern
`play PAT`

+ `PAT` is the name of a multi-pattern.
+ Plays `PAT` according to the underlying context of scale, root note, tempo, and MIDI
  sounds.


### Context management

#### Setting a scale
`set_scale STEP_1 ... STEP_k`

+ `STEP_1 ... STEP_k` is the integer composition of a $12$-scale.
+ Sets the underlying scale to the specified one.


#### Setting a root note
`set_root NOTE`

+ `NOTE` is the midi code of a note between $0$ and $127$.
+ Sets the root of the underlying set of notes.


#### Setting a tempo
`set_tempo VAL`

+ `VAL` is a nonnegative integer.
+ Sets the tempo as `VAL` bpm. In the score files, each beat is denoted as one eighth the
  duration of a whole note.


#### Setting voice sounds
`set_sounds SOUND_1 ... SOUND_m`

+ `SOUND_1 ... SOUND_m` is a sequence of General MIDI sounds, encoded as integers between
  $0$ and $127$.
+ Allocates to each potential $i$-th voice of each multi-pattern the specified sound.


### Multi-pattern manipulation

#### Naming a multi-pattern
`multi_pattern NAME PAT_STR`

+ `NAME` is an identifier.
+ `PAT_STR` is a string specifying a multi-pattern.
+ Bounds the specified identifier to the specified object. Any instruction having
  multi-patterns as arguments accept `NAME` as argument.


#### Transpose a multi-pattern
`transpose NAME PAT VAL`

+ `NAME` is an identifier.
+ `PAT` is the name of a multi-pattern.
+ `VAL` is an integer.
+ Bounds `NAME` to the multi-pattern defined as the transposition of `PAT` of `VAL` degrees.
  This value `VAL` can be negative.


#### Mirror image of a multi-pattern
`mirror NAME PAT`

+ `NAME` is an identifier.
+ `PAT` is the name of a multi-pattern.
+ Bounds `NAME` to the multi-pattern defined as the mirror image of `PAT`.


#### Concatenate multi-patterns
`concatenate NAME PAT_1 ... PAT_n`

+ `NAME` is an identifier.
+ `PAT_1 ... PAT_n` is a list a $m$-multi-patterns with $n \geq 2$.
+ Bounds `NAME` to the concatenation of `PAT_1 ... PAT_n`.


#### Repeat a multi-pattern
`repeat NAME PAT VAL`

+ `NAME` is an identifier.
+ `PAT` is the name of a multi-pattern.
+ `VAL` is a nonnegative integer.
+ Bounds `NAME` to the multi-pattern defined as the `VAL` times repetition of `PAT`.


#### Transform multi-patterns
`transform NAME PAT DIL M_1 ... M_m`

+ `NAME` is an identifier.
+ `PAT` is the name of an $m$-multi-pattern.
+ `DIL` is a nonnegative integer.
+ `M_1 ... M_m` is a sequence of integers.
+ Bounds `NAME` to the $m$-multi-pattern obtained by multiplying by `DIL` each rest and by
  multiplying each degree of the $i$-th voice of `PAT` by `M_i`.


#### Partially compose two multi-patterns
`partial_compose NAME PAT_1 POS PAT_2`

+ `NAME` is an identifier.
+ `PAT_1` is the name of an $m$-multi-pattern of arity $n$.
+ `POS` is an integer between $1$ and $n$.
+ `PAT_2` is the name an $m$-multi-pattern.
+ Bounds `NAME` to the partial composition of `PAT_2` at position `POS` in `PAT_1`.


#### Fully compose multi-patterns
`full_compose NAME PAT PAT_1 ... PAT_n`

+ `NAME` is an identifier.
+ `PAT` is the name of an $m$-multi-pattern of arity $n$.
+ `PAT_1`, ..., `PAT_n` are names of $m$-multi-patterns.
+ Bounds `NAME` to the full composition of `PAT` with `PAT_1`, ..., `PAT_n`.


#### Binarily compose two multi-patterns
`binarily_compose NAME PAT_1 PAT_2`

+ `NAME` is an identifier.
+ `PAT_1` is the name of an $m$-multi-pattern.
+ `PAT_2` is the name of an $m$-multi-pattern.
+ Bounds `NAME` to the binary composition of `PAT_1` with `PAT_2`.


### Bud grammar manipulation

#### Colorize a multi-pattern
`colorize NAME PAT OUT IN_1 ... IN_n`

+ `NAME` is an identifier.
+ `PAT` is a multi-pattern of arity $n$.
+ `OUT` is a color.
+ `IN_1 ... IN_n` is a list of colors.
+ Bounds the specified identifier to the colored multi-pattern obtained by surrounding the
 multi-pattern `PAT` with the output color `OUT` and the input colors `IN_1 ... IN_n`.

#### Randomly generate a multi-pattern
`generate NAME SHAPE SIZE COL CPAT_1 ... CPAT_n`

+ `NAME` is an identifier.
+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `COL` is a color.
+ `CPAT_1 ... CPAT_n` is a list of names of colored multi-patterns.
+ Bounds `NAME` to a pattern randomly generated from the inputted colored patterns, with the
  specified size, the specified generation shape, and the specified initial color. This uses
  bug generating systems and random generation algorithms.


### Specific random transformation of $1$-multi-patterns

#### Temporize a $1$-multi-pattern
`temporize NAME SHAPE SIZE PAT VAL`

+ `NAME` is an identifier.
+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `PAT` is the name of a $1$-multi-pattern.
+ `VAL` is a nonnegative integer.
+ Bounds `NAME` to the $1$-multi-pattern obtained by randomly composing `PAT` with itself
  and by incorporating some delays ranging between $1$ and `VAL`. This uses the generation
  algorithm with the specified shape and the specified size.


#### Rhythmize a $1$-multi-pattern
`rhythmize NAME SHAPE SIZE PAT R_PAT`

+ `NAME` is an identifier.
+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `PAT` is the name of a $1$-multi-pattern
+ `R_PAT` is the name of a $1$-multi-pattern with only rests or beat having $0$ as degree.
+ Bounds `NAME` to the $1$-multi-pattern obtained by randomly composing `PAT` with itself
  and by adding some repetitions of beats by following the specified rhythm pattern `R_PAT`.
  This uses the generation algorithm with the specified shape and the specified size.


#### Harmonize a $1$-multi-pattern
`harmonize NAME SHAPE SIZE PAT D_PAT`

+ `NAME` is an identifier.
+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `PAT` is the name of a $1$-multi-pattern, 
+ `D_PAT` is the name of a $1$-multi-pattern with no rest and of arity $m$.
+ Bounds `NAME` to the $m$-multi-pattern obtained by randomly composing `PAT` with itself
  and by harmonizing some of its degrees according to the degree-pattern `D_PAT`. This uses
  the generation algorithm with the specified shape and the specified size.


#### Arpeggiate a $1$-multi-pattern
`arpeggiate NAME SHAPE SIZE PAT D_PAT`

+ `NAME` is an identifier.
+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `PAT` is the name of a $1$-multi-pattern.
+ `D_PAT` is the name of a $1$-multi-pattern with no rest and of arity $m$.
+ Bounds `NAME` to the $m$-multi-pattern obtained by randomly composing `PAT` with itself
  and by arpeggiating some of its degrees according to the degree-pattern `D_PAT`. This uses
  the generation algorithm with the specified shape and the specified size.


#### Mobiusate a $1$-multi-pattern
`mobiusate NAME SHAPE SIZE PAT`

+ `NAME` is an identifier.
+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `PAT` is the name of a $1$-multi-pattern.
+ Bounds `NAME` to the $2$-multi-pattern obtained by randomly composing the
  $2$-multi-pattern obtained by stacking `PAT` with its mirror image. This uses the
  generation algorithm with the specified shape and the specified size.

