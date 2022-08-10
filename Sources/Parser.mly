(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020, apr. 2021, jul. 2022, aug. 2022
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
%token ADD_INT
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

%start <Program.program> program

%%

program:
    |lst=list(instruction) EOF {lst}

instruction:
    |SHOW {Program.Show}
    |WRITE mp_name=NAME file_name=NAME {Program.Write (mp_name, file_name)}
    |PLAY mp_name=NAME {Program.Play mp_name}
    |SCALE scale=nonempty_list(INTEGER) {Program.SetScale scale}
    |ROOT midi_note=INTEGER {Program.SetRoot midi_note}
    |TEMPO tempo=INTEGER {Program.SetTempo tempo}
    |SOUNDS midi_sounds=nonempty_list(INTEGER) {Program.SetSounds midi_sounds}
    |MONOID dm=monoid {Program.SetDegreeMonoid dm}
    |MULTI_PATTERN mp_name=NAME mp=multi_pattern {Program.MultiPattern (mp_name, mp)}
    |MIRROR res_name=NAME mp_name=NAME {Program.Mirror (res_name, mp_name)}
    |INVERSE res_name=NAME mp_name=NAME {Program.Inverse (res_name, mp_name)}
    |CONCATENATE res_name=NAME mp_names_lst=nonempty_list(NAME)
        {Program.Concatenate (res_name, mp_names_lst)}
    |REPEAT res_name=NAME mp_name=NAME k=INTEGER {Program.Repeat (res_name, mp_name, k)}
    |STACK res_name=NAME mp_names_lst=nonempty_list(NAME)
        {Program.Stack (res_name, mp_names_lst)}
    |PARTIAL_COMPOSE res_name=NAME mp_name_1=NAME pos=INTEGER mp_name_2=NAME
        {Program.PartialCompose (res_name, mp_name_1, pos, mp_name_2)}
    |FULL_COMPOSE res_name=NAME mp_name=NAME mp_names_lst=nonempty_list(NAME)
        {Program.FullCompose (res_name, mp_name, mp_names_lst)}
    |HOMOGENEOUS_COMPOSE res_name=NAME mp_name_1=NAME mp_name_2=NAME
        {Program.HomogeneousCompose (res_name, mp_name_1, mp_name_2)}
    |COLORIZE res_name=NAME out_color=color PIPE mp_name=NAME PIPE in_colors=list(color)
        {Program.Colorize (res_name, mp_name, out_color, in_colors)}
    |MONO_COLORIZE res_name=NAME out_color=color PIPE mp_name=NAME PIPE in_color=color
        {Program.MonoColorize (res_name, mp_name, out_color, in_color)}
    |GENERATE res_name=NAME shape=shape size=INTEGER color=color
            cmp_names_lst=nonempty_list(NAME)
        {Program.Generate (res_name, shape, size, color, cmp_names_lst)}

multi_pattern:
    |mp_lst=separated_nonempty_list(PLUS, pattern) {mp_lst}

pattern:
    |pat=list(atom) {pat}

atom:
    |DOT {Atom.Rest}
    |d=INTEGER {Atom.Beat d}

monoid:
    |ADD_INT {Program.AddInt}
    |CYCLIC k=INTEGER {Program.Cyclic k}
    |MAX z=INTEGER {Program.Max z}

color:
    |PERCENT c=NAME {c}

shape:
    |PARTIAL {BudGrammar.Partial}
    |FULL {BudGrammar.Full}
    |HOMOGENEOUS {BudGrammar.Homogeneous}

