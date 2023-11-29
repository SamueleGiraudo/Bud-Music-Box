# Bud Music Box language instruction set
This page describes the instruction set of the Bud Music Box language.

## General conventions
+ **Comments** are enclosed into symbols `{` and `}`. Nested comments are allowed.

+ **Integers** are expressed following the usual signed decimal notation.

  For instance, `0`, `127`, `-0`, `-17`,  and `- 17` are integers,

+ **Names** are strings of length at least $1$ and made of symbols in `a`-`z`, `A`-`Z`,
  `0`-`9`, `'`, or `_`, and starting with an alphabetic symbol, `'`, or `_`.

  For instance, `p`, `p'`, `pattern_`, `res_pat_1`, and `__new''` are names.

+ **Colors** are strings of length at least $2$, starting with `%` and then made of strings
  following the same rules as the ones of names.

  For instance, `%c`, `%c'`, `%col_`, `%col_1`, and `%__new_color''` are colors.

## Multi-patterns

### Syntax
A multi-pattern is specified by the sequence of its _atoms_, that are degrees (expressed by
signed decimal integers) or rests (expressed by `.`). The multiple voices in a multi-pattern
are separated by the `+` symbol.

For instance,
```
1 -1 . . 2 . 4   +   0 0 . 1 . -3 .   +   1 . 2 . 2 2 .
```
is a string specifying a multi-pattern.

### Definitions
A multi-pattern $p$ is _well-formed_ when
+ all voices of $p$ contain the same number of atoms;
+ all voices of $p$ contain the same number of degrees.

Here are some important definitions. Given a multi-pattern $p$,
+ the _length_ of $p$ is the number of atoms in any voice of $p$;
+ The _arity_ of $p$ is the number of degrees in any voice of $p$;
+ the _multiplicity_ of $p$ is the number of voices of $p$.

For instance, by considering the multi-pattern $p$ specified by the previous example,
+ the length of $p$ is $7$;
+ the arity of $p$ is $4$;
+ the multiplicity of $p$ is $3$.

## Messages
The output communicates three types of messages:
+ **error messages**, starting by `??`;
+ **information messages**, starting by `>>`;
+ **success messages**, starting by `!!`.

## Errors

### Syntax and type errors
The error message `?? Syntax error: in file PATH at line NUM_L and column NUM_C: parsing
error` says that there is an error in the `.bmb` file at path `PATH`, located on the
instruction having `NUM_L` as line number and `NUM_C` as column number.

These errors occur in two cases:
1. when there is a standard syntax error;
2. when an instruction gets an inappropriate value as argument. This occurs for example when
   a positive integer value is expected and a zero or a negative value is provided instead.

### Other errors
The errors which can be produced by each instruction are described in the sequel.

## Instruction set

### Control instructions
The _control instructions_ are the instructions `show`, `write`, and `play`.

#### Display information

##### Instruction
```
show
```

+ Prints the current internal data consisting of the specified data, including the scale,
  root note, tempo, General MIDI programs, degree monoid, and multi-patterns.

##### Possible errors
This instruction cannot produce errors.

#### Generate the associated files of a multi-pattern 

##### Instruction
```
write NAME
```

+ `NAME` is a name bound to a multi-pattern.
+ Creates, within the underlying context of scale, root note, tempo, and General MIDI
  programs,
    + an ABC file;
    + a postscript file;
    + a MIDI file;
  for the musical phrase encoded by the multi-pattern which is the value of `NAME`. The
  created files are obtained by adding adequate extensions to the path of the run `Bud Music
  Box` program. A suffix `_N` is inserted just before the file extensions where `N` is the
  seed of the random generation algorithm. This seed depends on when the program is run. It
  can be specified by the argument `--seed N`.

For instance, if the path of the run program is `Samples/First.bmb` and `pat` is a
well-defined identified of a multi-pattern, `write pat` creates the files
`Samples/First_0.abc`, `Samples/First_0.ps`, and `Samples/First_0.mid`. A second execution
of `write pat` creates the files `Samples/First_1.abc`, `Samples/First_1.ps`, and
`Samples/First_1.mid`.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when `NAME` is not bound to a multi-pattern.
+ `?? Scale not specified.`: occurs when no scale has been specified before executing this
  instruction.
+ `?? Root note not specified.`: occurs when no root note has been specified before
  executing this instruction.
+ `?? Tempo not specified.`: occurs when no tempo has been specified before executing this
  instruction.
+ `?? MIDI programs insufficiently specified.`: occurs when no enough General MIDI programs
  have been specified before executing this instruction.
+ `?? Degrees outside MIDI note range.`: occurs when a degree of the multi-pattern which is
  the value of `NAME` corresponds to a note outside the interval between `0` and `127`.

#### Play a multi-pattern

##### Instruction
```
play NAME
```

+ `NAME` is a name bound to a multi-pattern.
+ Plays the multi-pattern which is the value of `NAME` according to the underlying context
  of scale, root note, tempo, and General MIDI programs. This instruction create the same
  files as the ones generated by the instruction `write NAME`.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when `NAME` is not bound to a multi-pattern.
+ `?? Scale not specified.`: occurs when no scale has been specified before executing this
  instruction.
+ `?? Root note not specified.`: occurs when no root note has been specified before
  executing this instruction.
+ `?? Tempo not specified.`: occurs when no tempo has been specified before executing this
  instruction.
+ `?? General MIDI programs insufficiently specified.`: occurs when no enough General MIDI
  programs have been specified before executing this instruction.
+ `?? Degrees outside MIDI note range.`: occurs when a degree of the multi-pattern which is
  the value of `NAME` corresponds to a note outside the interval between `0` and `127`.
+ `?? Timidity failure.`: occurs when there is an error in playing the MIDI file of the
  multi-pattern which is the value of `NAME` raised by `timidity`.

### Context management
The _context management instructions_ are `scale`, `root`, `tempo`, `sounds`, and `monoid`.

#### Setting a scale

##### Instruction
```
scale STEP_1 ... STEP_k
```

+ `STEP_1 ... STEP_k` is an integer composition (also named _profile_) specifying a scale in
  the $12$-tone equal temperament system.
+ Sets the underlying scale to the specified one. If a scale was already set, this overrides
  the previous setting.

For instance, `scale 2 1 2 2 1 2 2` sets the minor natural scale as underlying scale.

##### Possible errors
+ `?? Not a 12-TET scale.`: occurs when the sum of the integers forming the composition is
  not $12$.

#### Setting a root note

##### Instruction
```
root NOTE
```

+ `NOTE` is the MIDI code of a note between $0$ and $127$.
+ Sets the root of the underlying set of notes. If a root was already set, this overrides
  the previous setting.

For instance, `root 60` sets the root note to the middle C.

##### Possible errors
+ `?? Invalid MIDI note code.`: occurs when the `NOTE` is outside the interval between `0`
  and `127`.

#### Setting a tempo

##### Instruction
```
tempo VAL
```

+ `VAL` is a nonnegative integer.
+ Sets the tempo as `VAL` bpm. In each generated score files, each beat is denoted as one
  quarter note and each rest is denoted as one quarter rest. The tempo specifies the number
  of each of these in one minute. If a tempo was already set, this overrides the previous
  setting.

For instance, `tempo 96` sets the tempo to `96` bpm.

##### Possible errors
This instruction cannot produce errors.

#### Setting voice sounds

##### Instruction
```
sounds SOUND_1 ... SOUND_m
```

+ `SOUND_1 ... SOUND_m` is a sequence of General MIDI sound programs, encoded as integers
  between $0$ and $127$.
+ Allocates to each potential $i$-th voice of each multi-pattern the specified sound. If a
  sequence of General MIDI programs was already set, this overrides the previous setting.

For instance, `sounds 0 108` allocates to the $1$-st voice the _Acoustic Grand Piano_
General MIDI program and to the $2$-nd voice, the _Kalimba_ General MIDI program.

##### Possible errors
+ `?? Invalid General MIDI programs.`: occurs when a General MIDI sound program `SOUND_i` is
  outside the interval between `0` and `127`.

#### Setting a degree monoid

##### Instruction
```
monoid DM
```

+ `DM` is a degree monoid among the five possible ones:
    + `add`, for the additive monoid on integers;
    + `cyclic K`, for the cyclic monoid of order `K`, where `K` is a positive integer;
    + `mul`, for the multiplicative monoid on integers;
    + `mul-mod K`, for the multiplicative monoid modulo `K`, where `K` is a positive
      integer;
    + `max Z`, for the monoid on integers nonsmaller than `Z` for the $\max$ operation,
      where `Z` is an integer.
+ Set the underlying degree monoid, specifying how to perform products on degrees for the
  compositions in the operads of multi-patterns. If a degree monoid was already set, this
  overrides the previous setting.

For instance, `monoid cyclic 7` set the cyclic monoid of order $7$ as degree monoid.

##### Possible errors
+ `?? Degree monoid not compatible with existing multi-patterns.`: occurs when an already
  defined name is bound to a multi-pattern having a degree which is not an element of the
  specified degree monoid.
+ `?? Degree monoid not compatible with existing colored multi-patterns.`: occurs when an
  already defined name is bound to a colored multi-pattern having a degree which is not an
  element of the specified degree monoid.

### Multi-pattern manipulation
The _multi-pattern manipulation instructions_ are `multi-pattern`, `mirror`, `inverse`,
`concatenate`, `concatenate-repeat`, `stack`, `stack-repeat`, `partial-compose`,
`full-compose`, and `homogeneous-compose`.

#### Naming a multi-pattern

##### Instruction
```
multi-pattern NAME_RES PAT
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `PAT` is a string specifying a multi-pattern.
+ Bounds `NAME_RES` to the multi-pattern specified by `PAT`. In the case where `NAME_RES` is
  already bound to a multi-pattern, this instruction overrides the previous definition.

For instance,
```
multi-pattern p1 0 . . 1 2 3 . .   +   0 -5 . . . . 0 0
```
bounds the name `p1` to the specified multi-pattern.

##### Possible errors
+ `?? Bad multi-pattern.`: occurs when `PAT` does not specify a well-formed multi-pattern.
+ `?? Degree monoid not specified.`: occurs when no degree monoid has been specified before
  executing this instruction.
+ `?? Multi-pattern not on degree monoid.`: occurs when `PAT` contains a degree which is not
  an element of the underlying degree monoid.

#### Mirror image of a multi-pattern

##### Instruction
```
mirror NAME_RES NAME_SOURCE
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `NAME_SOURCE` is a name bound to a multi-pattern.
+ Bounds `NAME_RES` to the multi-pattern defined as the mirror image of the multi-pattern
  which is the value of `NAME_SOURCE`. In the case where `NAME_RES` is already bound to a
  multi-pattern, this instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when `NAME_SOURCE` is not bound to a
  multi-pattern.

#### Inverse image of a multi-pattern

##### Instruction
```
inverse NAME_RES NAME_SOURCE
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `NAME_SOURCE` is a name bound to a multi-pattern.
+ Bounds `NAME_RES` to the multi-pattern defined as the inverse image of the multi-pattern
  which is the value of `NAME_SOURCE`. In the case where `NAME_RES` is already bound to a
  multi-pattern, this instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when `NAME_SOURCE` is not bound to a
  multi-pattern.
+ `?? Resulting multi-pattern not on degree monoid.`: occurs when the computed pattern
  admits a degree which does not belong to the underlying degree monoid.

#### Concatenate multi-patterns

##### Instruction
```
concatenate NAME_RES NAME_SOURCE_1 ... NAME_SOURCE_n
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `NAME_SOURCE_1 ... NAME_SOURCE_n` is a sequence of names bound to multi-patterns.
+ Bounds `NAME_RES` to the multi-pattern defined as the concatenation of the multi-patterns
  which are the value of `NAME_SOURCE_1`, ..., `NAME_SOURCE_n`. In the case where `NAME_RES`
  is already bound to a multi-pattern, this instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when there is a `NAME_SOURCE_i` which is not
  bound to a multi-pattern.
+ `?? Bad multiplicity of multi-patterns.`: occurs when the multi-patterns which are values
  of `NAME_SOURCE_1`, ..., `NAME_SOURCE_n` have different multiplicities.

#### Repeat a multi-pattern with respect to concatenation

##### Instruction
```
concatenate-repeat NAME_RES NAME_SOURCE N
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `NAME_SOURCE` is a name bound to a multi-pattern.
+ `N` is a positive integer.
+ Bounds `NAME_RES` to the multi-pattern defined as the concatenation of the multi-pattern
  which is the value of `NAME_SOURCE` with itself `N` times. In the case where `NAME_RES` is
  already bound to a multi-pattern, this instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when `NAME_SOURCE` is not bound to a
  multi-pattern.

#### Stack multi-patterns

##### Instruction
```
stack NAME_RES NAME_SOURCE_1 ... NAME_SOURCE_n
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `NAME_SOURCE_1 ... NAME_SOURCE_n` is a sequence of names bound to multi-patterns.
+ Bounds `NAME_RES` to the multi-pattern defined as the stack of the multi-patterns
  which are the value of `NAME_SOURCE_1`, ..., `NAME_SOURCE_n`. In the case where `NAME_RES`
  is already bound to a multi-pattern, this instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when there is a `NAME_SOURCE_i` which is not
  bound to a multi-pattern.
+ `?? Bad arity of multi-patterns.`: occurs when the multi-patterns which are values
  of `NAME_SOURCE_1`, ..., `NAME_SOURCE_n` have different arities.
+ `?? Bad length of multi-patterns.`: occurs when the multi-patterns which are values
  of `NAME_SOURCE_1`, ..., `NAME_SOURCE_n` have different length.

#### Repeat a multi-pattern with respect to stack

##### Instruction
```
stack-repeat NAME_RES NAME_SOURCE N
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `NAME_SOURCE` is a name bound to a multi-pattern.
+ `N` is a positive integer.
+ Bounds `NAME_RES` to the multi-pattern defined as the stack of the multi-pattern which is
  the value of `NAME_SOURCE` with itself `N` times. In the case where `NAME_RES` is already
  bound to a multi-pattern, this instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when `NAME_SOURCE` is not bound to a
  multi-pattern.

#### Partial composition of two multi-patterns

##### Instruction
```
partial-compose NAME_RES NAME_SOURCE_1 POS NAME_SOURCE_2
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `NAME_SOURCE_1` is a name bound to a multi-pattern.
+ `POS` is a positive integer.
+ `NAME_SOURCE_2` is a name bound to a multi-pattern.
+ Bounds `NAME_RES` to the multi-pattern defined as the partial composition of the
  multi-pattern which is the value of `NAME_SOURCE_2` at position `POS` in the multi-pattern
  which is the value of `NAME_SOURCE_1`. In the case where `NAME_RES` is already bound to a
  multi-pattern, this instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when `NAME_SOURCE_1` or `NAME_SOURCE_2` are not
  bound to multi-patterns.
+ `?? Bad multiplicity of multi-patterns.`: occurs when the multi-patterns which are values
  of `NAME_SOURCE_1` and `NAME_SOURCE_2` have different multiplicities.
+ `?? Bad partial composition position.`: occurs when `POS` is greater than the arity of the
  multi-pattern which is the value of `NAME_SOURCE_1`.

#### Full composition of multi-patterns

##### Instruction
```
full-compose NAME_RES NAME_SOURCE_0 NAME_SOURCE_1 ... NAME_SOURCE_n
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `NAME_SOURCE_0 NAME_SOURCE_1 ... NAME_SOURCE_n` is a sequence of names bound to
   multi-patterns.
+ Bounds `NAME_RES` to the multi-pattern defined as the full composition of the
  multi-patterns which are values of `NAME_SOURCE_1`, ..., `NAME_SOURCE_N` into the
  multi-pattern which is the value of `NAME_SOURCE_0`. In the case where `NAME_RES` is
  already bound to a multi-pattern, this instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when there is a `NAME_SOURCE_i` which is not
  bound to a multi-pattern.
+ `?? Bad number of multi-patterns.`: occurs when `n` is different to the arity of the
  multi-pattern which is the value of `NAME_SOURCE_0`.
+ `?? Bad multiplicity of multi-patterns.`: occurs when the multi-patterns which are values
  of `NAME_SOURCE_0`, `NAME_SOURCE_1`, ..., `NAME_SOURCE_n` have different multiplicities.

#### Homogeneous composition of two multi-patterns

##### Instruction
```
homogeneous-compose NAME_RES NAME_SOURCE_1 NAME_SOURCE_2
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `NAME_SOURCE_1` and `NAME_SOURCe_2` are name bound to multi-patterns.
+ Bounds `NAME_RES` to the multi-pattern defined as the homogeneous composition of the
  multi-pattern which is the value of `NAME_SOURCE_2` in the multi-pattern which is the
  value of `NAME_SOURCE_1`. In the case where `NAME_RES` is already bound to a
  multi-pattern, this instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when `NAME_SOURCE_1` or `NAME_SOURCE_2` are not
  bound to multi-patterns.
+ `?? Bad multiplicity of multi-patterns.`: occurs when the multi-patterns which are values
  of `NAME_SOURCE_1` and `NAME_SOURCE_2` have different multiplicities.

### Bud grammar manipulation
The _bud grammar manipulation instructions_ are the instructions `colorize`,
`mono-colorize`, and `generate`.

#### Colorize a multi-pattern

##### Instruction
```
colorize NAME_RES %OUT NAME_SOURCE %IN_1 ... %IN_n
```

+ `NAME_RES` is a name, which is bound or not to a colored multi-pattern.
+ `%OUT` is a color.
+ `NAME_SOURCE` is a name bound to a multi-pattern.
+ `%IN_1 ... %IN_n` is a sequence of colors.
+ Bounds `NAME_RES` to the colored multi-pattern made of the multi-pattern which is the
  value of `NAME_SOURCE`, surrounded by the output color `%OUT` and the input colors `%IN_1
  ... %IN_n`. In the case where `NAME_RES` is already bound to a colored multi-pattern, this
  instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when `NAME_SOURCE` is not bound to a
  multi-pattern.
+ `?? Colored multi-pattern added.`: occurs when `n` is different to the arity of the
  multi-pattern which is the value of `NAME_SOURCE`.

#### Mono-colorize a multi-pattern

##### Instruction
```
mono-colorize NAME_RES %OUT NAME_SOURCE %IN
```

+ `NAME_RES` is a name, which is bound or not to a colored multi-pattern.
+ `%OUT` is a color.
+ `NAME_SOURCE` is a name bound to a multi-pattern.
+ `%IN` is a color.
+ Bounds `NAME_RES` to the colored multi-pattern made of the multi-pattern which is the
  value of `NAME_SOURCE`, surrounded by the output color `%OUT` and the input colors `%IN`
  repeated an adequate number of times. In the case where `NAME_RES` is already bound to a
  colored multi-pattern, this instruction overrides the previous definition.

##### Possible errors
+ `?? Unknown multi-pattern name.`: occurs when `NAME_SOURCE` is not bound to a
  multi-pattern.

#### Randomly generate a multi-pattern

##### Instruction
```
generate NAME_RES SHAPE K %INIT NAME_SOURCE_1 ... NAME_SOURCE_n
```

+ `NAME_RES` is a name, which is bound or not to a multi-pattern.
+ `SHAPE` is `partial`, `full`, or `colored`.
+ `K` is a nonnegative integer value.
+ `%INIT` is a color.
+ `NAME_SOURCE_1 ... NAME_SOURCE_n` is a sequence of names bound to colored multi-patterns.
+ Bounds `NAME_RES` to a multi-pattern randomly generated by considering the growing
  strategy specified by `SHAPE`, with `K` steps, from from the initial color `%INIT`, and
  using the colored multi-patterns which are values of `NAME_SOURCE_1`, ...,
  `NAME_SOURCE_n`.

##### Possible errors
+ `?? Unknown colored multi-pattern name.`: occurs when there is a `NAME_SOURCE_i` which is
  not bound to a colored multi-pattern.
+ `?? Bad multiplicity of multi-patterns.`: occurs when the colored multi-patterns which are
  values of `NAME_SOURCE_1`, ..., `NAME_SOURCE_n` have different multiplicities.

