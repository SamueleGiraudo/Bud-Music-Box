# Bud Music Box language instruction set
This page describes all the instructions of the Bud Music Box language.


## General conventions
Comments are enclosed into symbols `{` and `}`. Nested comments are allowed.

Identifiers are strings made of symbols in `a`-`z`, `A`-`Z`, `0`-`9`, or `_`, and starting
with an alphabetic symbol or `_`.


## Syntax for multi-patterns
A multi-pattern is specified by the sequence of its atoms, that are degrees (expressed by
signed decimal integers) or rests (expressed by `.`). The multiple voices of a multi-pattern
are separated by a `+`.

For instance,
```
1 -1 . . 2 . 4 + 0 0 . 1 . -3 . + 1 . 2 . 2 2 . + . 0 . 0 0 . 0
```
is a string specifying a multi-pattern of multiplicity $4$. The multiplicity is the number
of voices. This multi-pattern has arity $4$ because each voice contains $4$ beats. The
length of this multi-pattern is $7$ since each voice has seven atom, where an atom is either
a beat or a rest. Therefore, this multi-pattern lasts $7$ amounts of time.


## Instruction set

### Control instructions


#### Display information
`show`

+ Prints the current internal data (scale, tempo, patterns, _etc._).


#### Write the associated files of a multi-pattern 
`write FILE_NAME PAT`

+ `FILE_NAME` is a path to a non-existing file without extension.
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
`scale STEP_1 ... STEP_k`

+ `STEP_1 ... STEP_k` is the integer composition of a $12$-scale.
+ Sets the underlying scale to the specified one.

By default, the minor natural scale `2 1 2 2 1 2 2` is used.


#### Setting a root note
`root NOTE`

+ `NOTE` is the midi code of a note between $0$ and $127$.
+ Sets the root of the underlying set of notes.

By default, the root note `57` is used.


#### Setting a tempo
`tempo VAL`

+ `VAL` is a nonnegative integer.
+ Sets the tempo as `VAL` bpm. In the score files, each beat is denoted as one quarter note
  and each rest is denoted as one quarter rest. The tempo specifies the number of each of
  these in one minute.

By default, the tempo of `120` is used.


#### Setting voice sounds
`sounds SOUND_1 ... SOUND_m`

+ `SOUND_1 ... SOUND_m` is a sequence of General MIDI sounds, encoded as integers between
  $0$ and $127$.
+ Allocates to each potential $i$-th voice of each multi-pattern the specified sound.

By default, the sounds `108` are used.


### Setting a degree monoid
`monoid DM`

+ `DM` is a degree monoid among the three possible ones: `add_int` (for the additive monoid
  on all integers), `cyclic $k$` (for the cyclic monoid of order $k$), `max $z$` (for the
  monoid on all integers nonsmaller than $z$ for the `max` operation).
+ This encodes how to perform products on degrees for the compositions the operads of
  multi-patterns.

By default, the additive degree monoid is used.


### Multi-pattern manipulation

#### Naming a multi-pattern
`multi-pattern NAME PAT_STR`

+ `NAME` is an identifier.
+ `PAT_STR` is a string specifying a multi-pattern.
+ Bounds the specified identifier to the specified object. Any instruction having
  multi-patterns as arguments accept `NAME` as argument.


#### Mirror image of a multi-pattern
`mirror NAME PAT`

+ `NAME` is an identifier.
+ `PAT` is the name of a multi-pattern.
+ Bounds `NAME` to the multi-pattern defined as the mirror image of `PAT`.


#### Inverse image of a multi-pattern
`inverse NAME PAT`

+ `NAME` is an identifier.
+ `PAT` is the name of a multi-pattern.
+ Bounds `NAME` to the multi-pattern defined as the inverse image of `PAT`.


#### Concatenate multi-patterns
`concatenate NAME PAT_1 ... PAT_n`

+ `NAME` is an identifier.
+ `PAT_1 ... PAT_n` is a list of $m$-multi-patterns names with $n \geq 2$.
+ Bounds `NAME` to the concatenation of `PAT_1 ... PAT_n`.


#### Repeat a multi-pattern
`repeat NAME PAT VAL`

+ `NAME` is an identifier.
+ `PAT` is the name of a multi-pattern.
+ `VAL` is a nonnegative integer.
+ Bounds `NAME` to the multi-pattern defined as the `VAL` times repetition of `PAT`.


#### Stack multi-patterns
`stack NAME PAT_1 ... PAT_n`

+ `NAME` is an identifier.
+ `PAT_1 ... PAT_n` is a list of $m$-multi-patterns names with $n \geq 2$.
+ Bounds `NAME` to the stacking of `PAT_1 ... PAT_n`.


#### Partial composition of two multi-patterns
`partial-compose NAME PAT_1 POS PAT_2`

+ `NAME` is an identifier.
+ `PAT_1` is the name of an $m$-multi-pattern of arity $n$.
+ `POS` is an integer between $1$ and $n$.
+ `PAT_2` is the name an $m$-multi-pattern.
+ Bounds `NAME` to the partial composition of `PAT_2` at position `POS` in `PAT_1`.


#### Full composition of multi-patterns
`full-compose NAME PAT PAT_1 ... PAT_n`

+ `NAME` is an identifier.
+ `PAT` is the name of an $m$-multi-pattern of arity $n$.
+ `PAT_1`, ..., `PAT_n` are names of $m$-multi-patterns.
+ Bounds `NAME` to the full composition of `PAT` with `PAT_1`, ..., `PAT_n`.


#### Homogeneous composition of two multi-patterns
`binarily-compose NAME PAT_1 PAT_2`

+ `NAME` is an identifier.
+ `PAT_1` is the name of an $m$-multi-pattern.
+ `PAT_2` is the name of an $m$-multi-pattern.
+ Bounds `NAME` to the binary composition of `PAT_1` with `PAT_2`.


### Bud grammar manipulation

#### Colorize a multi-pattern
`colorize NAME %OUT | PAT | %IN_1 ... %IN_n`

+ `NAME` is an identifier.
+ `OUT` is a color.
+ `PAT` is a multi-pattern of arity $n$.
+ `IN_1 ... IN_n` is a list of colors.
+ Bounds the specified identifier to the colored multi-pattern obtained by surrounding the
  multi-pattern `PAT` with the output color `OUT` and the input colors `IN_1 ... IN_n`.


#### Mono-colorize a multi-pattern
`mono-colorize NAME %OUT | PAT | %IN`

+ `NAME` is an identifier.
+ `OUT` is a color.
+ `PAT` is a multi-pattern of arity $n$.
+ `IN` is a color.
+ Bounds the specified identifier to the colored multi-pattern obtained by surrounding the
  multi-pattern `PAT` with the output color `OUT` and the input colors `IN ... IN`.


#### Randomly generate a multi-pattern
`generate NAME SHAPE SIZE %COL CPAT_1 ... CPAT_n`

+ `NAME` is an identifier.
+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `COL` is a color.
+ `CPAT_1 ... CPAT_n` is a list of names of colored multi-patterns.
+ Bounds `NAME` to a pattern randomly generated from the inputted colored patterns, with the
  specified size, the specified generation shape, and the specified initial color. This uses
  bud generating systems and random generation algorithms.

