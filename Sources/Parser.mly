(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020, apr. 2021, jul. 2022, aug. 2022, nov. 2023
 *)

%token PLUS
%token DOT
%token PERCENT
%token PIPE

%token SHOW
%token WRITE
%token PLAY
%token SCALE
%token ROOT
%token TEMPO
%token SOUNDS
%token MONOID
%token ADD
%token CYCLIC
%token MAX
%token MULTI_PATTERN
%token MIRROR
%token INVERSE
%token CONCATENATE
%token REPEAT
%token STACK
%token PARTIAL_COMPOSE
%token FULL_COMPOSE
%token HOMOGENEOUS_COMPOSE
%token COLORIZE
%token MONO_COLORIZE
%token GENERATE
%token PARTIAL
%token FULL
%token HOMOGENEOUS

%token <int> INTEGER
%token <string> NAME

%token EOF

%start <Programs.programs> program

%%

program:
    |lst=list(instruction) EOF {lst}

instruction:
    |SHOW {Programs.Show}
    |WRITE mp_name=NAME file_name=NAME {Programs.Write (mp_name, file_name)}
    |PLAY mp_name=NAME {Programs.Play mp_name}
    |SCALE scale=nonempty_list(INTEGER) {Programs.SetScale (Scales.Scale scale)}
    |ROOT midi_note=INTEGER {Programs.SetRoot midi_note}
    |TEMPO tempo=INTEGER {Programs.SetTempo tempo}
    |SOUNDS midi_sounds=nonempty_list(INTEGER) {Programs.SetSounds midi_sounds}
    |MONOID dm=monoid {Programs.SetDegreeMonoid dm}
    |MULTI_PATTERN mp_name=NAME mp=multi_pattern {Programs.MultiPattern (mp_name, mp)}
    |MIRROR res_name=NAME mp_name=NAME {Programs.Mirror (res_name, mp_name)}
    |INVERSE res_name=NAME mp_name=NAME {Programs.Inverse (res_name, mp_name)}
    |CONCATENATE res_name=NAME mp_names_lst=nonempty_list(NAME)
        {Programs.Concatenate (res_name, mp_names_lst)}
    |REPEAT res_name=NAME mp_name=NAME k=INTEGER {Programs.Repeat (res_name, mp_name, k)}
    |STACK res_name=NAME mp_names_lst=nonempty_list(NAME)
        {Programs.Stack (res_name, mp_names_lst)}
    |PARTIAL_COMPOSE res_name=NAME mp_name_1=NAME pos=INTEGER mp_name_2=NAME
        {Programs.PartialCompose (res_name, mp_name_1, pos, mp_name_2)}
    |FULL_COMPOSE res_name=NAME mp_name=NAME mp_names_lst=nonempty_list(NAME)
        {Programs.FullCompose (res_name, mp_name, mp_names_lst)}
    |HOMOGENEOUS_COMPOSE res_name=NAME mp_name_1=NAME mp_name_2=NAME
        {Programs.HomogeneousCompose (res_name, mp_name_1, mp_name_2)}
    |COLORIZE res_name=NAME out_color=color PIPE mp_name=NAME PIPE in_colors=list(color)
        {Programs.Colorize (res_name, mp_name, out_color, in_colors)}
    |MONO_COLORIZE res_name=NAME out_color=color PIPE mp_name=NAME PIPE in_color=color
        {Programs.MonoColorize (res_name, mp_name, out_color, in_color)}
    |GENERATE res_name=NAME shape=shape size=INTEGER color=color
            cmp_names_lst=nonempty_list(NAME)
        {Programs.Generate (res_name, shape, size, color, cmp_names_lst)}

multi_pattern:
    |mp_lst=separated_nonempty_list(PLUS, pattern) {mp_lst}

pattern:
    |pat=list(atom) {pat}

atom:
    |DOT {Atoms.Rest}
    |n=INTEGER {Atoms.Beat (Degrees.Degree n)}

monoid:
    |ADD {Programs.Add}
    |CYCLIC k=INTEGER {Programs.Cyclic k}
    |MAX z=INTEGER {Programs.Max z}

color:
    |PERCENT c=NAME {c}

shape:
    |PARTIAL {BudGrammars.Partial}
    |FULL {BudGrammars.Full}
    |HOMOGENEOUS {BudGrammars.Homogeneous}

