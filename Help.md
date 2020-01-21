% Bud Music Box language
% Samuele Giraudo
% January 2020


## General conventions

Each single instruction fits on one line. All characters following a `#` in a given line are
ignored and can therefore be treated as comments.

Identifiers are strings made of the symbols in `a`-`z`, `A`-`Z`, `0`-`9`, or `_`.


## Syntax for multi-patterns and colored multi-patterns
TODO


## Instruction set

### Quit
`quit`

+ Quits the application.


### Help
`help`

+ Prints the help.


### Display information
`show`

+ Prints the current internal data (scale, tempo, patterns, _etc._).


### Setting a scale
`set_scale STEP_1 ... STEP_k`

+ `STEP_1 ... STEP_k` is the integer composition of a 12-scale.
+ Sets the underlying scale to the specified one.


### Setting a root note
`set_root NOTE`

+ `NOTE` is the midi code of a note between `0` and `127`.
+ Sets the root of the underlying set of notes.


### Setting a tempo
`set_tempo VAL`

+ `VAL` is a nonnegative integer.
+ Sets the tempo as `VAL` bpm. In the score files, each beat is denoted as one eighth the
  duration of a whole note.


### Setting voice sounds
`set_sounds SOUND_1 ... SOUND_m`

+ `SOUND_1 ... SOUND_m` is a sequence of General MIDI sounds, encoded as integers between
  `0` and `127`.
+ Allocates to each potential `i`-th voice of each multi-pattern the specified sound.


### Naming a multi-pattern
`$NAME := multi_pattern PAT`

+ `NAME` is an identifier.
+ `PAT` is a multi-pattern.
+ Bounds the specified identifier to the specified object. Any instruction having
  multi-patterns as arguments accept `$NAME` as argument.


### Naming a colored multi-pattern
`$NAME := colored_multi_pattern CPAT`

+ `NAME` is an identifier.
+ `CPAT` is a colored multi-pattern.
+ Bounds the specified identifier to the specified object. Any instruction having
  colored multi-patterns as arguments accept `$NAME` as argument.


### Partially compose two multi-patterns
`$NAME := partial_compose $PAT_1 POS $PAT_2`

+ `NAME` is an identifier.
+ `PAT_1` is the name of an m-multi-pattern of arity n.
+ `PAT_2` is the name an m-multi-pattern.
+ `POS` is an integer between `1` and n.
+ Bounds `NAME` to the partial composition of `PAT_2` at position `POS` in `PAT_1`.


### Fully compose multi-patterns
`$NAME := full_compose $PAT $PAT_1 ... $PAT_n`

+ `PAT` is the name of an m-multi-pattern of arity n.
+ `PAT_1`, ..., `PAT_n` are names of m-multi-patterns.
+ Returns the full composition of `PAT` with `PAT_1`, ..., `PAT_n`.


### Transform multi-patterns
`$NAME := transform DIL M_1 ... M_m $PAT`

+ `DIL` is a nonnegative integer.
+ `M_1 ... M_m` is a sequence of integers.
+ `PAT` is the name of an m-multi-pattern.
+ Returns the m-multi-pattern obtained by multiplying by `DIL` each rest and by
  multiplying each degree of the `i`-th voice of `PAT` by `M_i`.


### Mirror image of a multi-pattern
`$NAME := mirror $PAT`

+ `PAT` is the name of a multi-pattern.
+ Returns the multi-pattern defined as the mirror image of `PAT`.


### Randomly generate a multi-pattern
`$NAME := generate SHAPE SIZE COL $CPAT_1 ... $CPAT_n`

+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `COL` is a color.
+ `$CPAT_1 ... $CPAT_n` is a list of names of colored multi-patterns.
+ Returns a pattern randomly generated from the inputted colored patterns, with the
  specified size, the specified generation shape, and the specified initial color.


### Temporize a 1-multi-pattern
`$NAME := temporize SHAPE SIZE $PAT VAL`

+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `PAT` is the name of a 1-multi-pattern.
+ `VAL` is a nonnegative integer.
+ Returns the 1-multi-pattern obtained by randomly composing `PAT` with itself and by
  incorporating some delays ranging between `1` and `VAL`. This use the generation algorithm
  with the specified shape and the specified size.


### Rhythmize a 1-multi-pattern
`$NAME := rhythmize SHAPE SIZE $PAT $R_PAT`

+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `PAT` is the name of a 1-multi-pattern
+ `R_PAT` is the name of a 1-multi-pattern with only rests or beat having `0` as degree.
+ Returns the 1-multi-pattern obtained by randomly composing `PAT` with itself and by adding
  some repetitions of beats by following the specified rhythm pattern `R_PAT`. This use the
  generation algorithm with the specified shape and the specified size.


### Harmonize a 1-multi-pattern
`$NAME := harmonize SHAPE SIZE $PAT $D_PAT`

+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `PAT` is the name of a 1-multi-pattern, 
+ `D_PAT` is the name of a 1-multi-pattern with no rest and of arity `m`.
+ Returns the m-multi-pattern obtained by randomly composing `PAT` with itself and by
  harmonizing some of its degrees according to the degree-pattern `D_PAT`. This use the
  generation algorithm with the specified shape and the specified size.


### Arpeggiate a 1-multi-pattern
`$NAME := arpeggiate SHAPE SIZE $PAT $D_PAT`

+ `SHAPE` is `partial`, `full`, or `colored`.
+ `SIZE` is a nonnegative integer value.
+ `PAT` is the name of a 1-multi-pattern.
+ `D_PAT` is the name of a 1-multi-pattern with no rest and of arity `m`.
+ Returns the m-multi-pattern obtained by randomly composing `PAT` with itself and by
  arpeggiating some of its degrees according to the degree-pattern `D_PAT`. This use the
  generation algorithm with the specified shape and the specified size.


### Generate the associated files of a multi-pattern 
`write FILE_NAME $PAT`

+ `FILE_NAME` is a path to a non-existing file.
+ `PAT` is the name of a multi-pattern.
+ Creates the ABC file, postscript file, and MIDI file for the musical phrase encoded by the
  multi-pattern `PAT`, with the underlying context of scale, root note, tempo, and MIDI
  sounds. The created files are obtained by adding an adequate extension to `FILE_NAME`.


### Play multi-pattern
`play $PAT`

+ `PAT` is the name of a multi-pattern.
+ Plays `PAT` according to the underlying context of scale, root note, tempo, and MIDI
  sounds.


