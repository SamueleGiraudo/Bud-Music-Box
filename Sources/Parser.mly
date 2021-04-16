(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020, apr. 2021
 *)

%token SEMICOLON
%token STAR

%token SHOW
%token WRITE
%token PLAY
%token SET_SCALE
%token SET_ROOT
%token SET_TEMPO
%token SET_SOUNDS
%token MULTI_PATTERN
(*%token TRANSPOSE*)
%token MIRROR
(*%token CONCATENATE*)
(*%token REPEAT*)
(*%token TRANSFORM*)
%token PARTIAL_COMPOSE
%token FULL_COMPOSE
%token HOMOGENEOUS_COMPOSE
%token COLORIZE
%token GENERATE
%token PARTIAL
%token FULL
%token COLORED
%token TEMPORIZE
%token RHYTHMIZE
%token HARMONIZE
%token ARPEGGIATE
%token MOBIUSATE

%token <int> INTEGER
%token <string> NAME

%token EOF

%start <Program.program> program

%%

program:
    |lst=list(instruction) EOF
        {lst}

instruction:
    |SHOW
        {Program.Show}
    |WRITE mpat_name=NAME file_name=NAME
        {Program.Write (mpat_name, file_name)}
    |PLAY mpat_name=NAME
        {Program.Play mpat_name}
    |SET_SCALE scale=nonempty_list(INTEGER)
        {Program.SetScale scale}
    |SET_ROOT midi_note=INTEGER
        {Program.SetRoot midi_note}
    |SET_TEMPO tempo=INTEGER
        {Program.SetTempo tempo}
    |SET_SOUNDS midi_sounds=nonempty_list(INTEGER)
        {Program.SetSounds midi_sounds}
    |MULTI_PATTERN mpat_name=NAME mpat=multi_pattern
        {Program.MultiPattern (mpat_name, mpat)}
    (*
    |TRANSPOSE res_name=NAME mpat_name=NAME k=INTEGER
        {Program.Transpose (res_name, mpat_name, k)}
    *)
    |MIRROR res_name=NAME mpat_name=NAME
        {Program.Mirror (res_name, mpat_name)}
    (*
    |CONCATENATE res_name=NAME mpat_names_lst=nonempty_list(NAME)
        {Program.Concatenate (res_name, mpat_names_lst)}
    |REPEAT res_name=NAME mpat_name=NAME k=INTEGER
        {Program.Repeat (res_name, mpat_name, k)}
    *)
    (*
    |TRANSFORM res_name=NAME mpat_name=NAME dilatation=INTEGER
            mul_lst=nonempty_list(INTEGER)
        {Program.Transform (res_name, mpat_name, dilatation, mul_lst)}
    *)
    |PARTIAL_COMPOSE res_name=NAME mpat_name_1=NAME pos=INTEGER mpat_name_2=NAME
        {Program.PartialCompose (res_name, mpat_name_1, pos, mpat_name_2)}
    |FULL_COMPOSE res_name=NAME mpat_name=NAME mpat_names_lst=nonempty_list(NAME)
        {Program.FullCompose (res_name, mpat_name, mpat_names_lst)}
    |HOMOGENEOUS_COMPOSE res_name=NAME mpat_name_1=NAME mpat_name_2=NAME
        {Program.HomogeneousCompose (res_name, mpat_name_1, mpat_name_2)}
    |COLORIZE res_name=NAME mpat_name=NAME out_color=NAME in_colors=nonempty_list(NAME)
        {Program.Colorize (res_name, mpat_name, out_color, in_colors)}
    |GENERATE res_name=NAME shape=shape size=INTEGER color=NAME
            cpat_names_lst=nonempty_list(NAME)
        {Program.Generate (res_name, shape, size, color, cpat_names_lst)}
    |TEMPORIZE res_name=NAME shape=shape size=INTEGER pat_name=NAME max_delay=INTEGER
        {Program.Temporize (res_name, shape, size, pat_name, max_delay)}
    |RHYTHMIZE res_name=NAME shape=shape size=INTEGER pat_name=NAME rpat_name=NAME
        {Program.Rhythmize (res_name, shape, size, pat_name, rpat_name)}
    |HARMONIZE res_name=NAME shape=shape size=INTEGER pat_name=NAME dpat_name=NAME
        {Program.Harmonize (res_name, shape, size, pat_name, dpat_name)}
    |ARPEGGIATE res_name=NAME shape=shape size=INTEGER pat_name=NAME dpat_name=NAME
        {Program.Arpeggiate (res_name, shape, size, pat_name, dpat_name)}
    |MOBIUSATE res_name=NAME shape=shape size=INTEGER pat_name=NAME
        {Program.Mobiusate (res_name, shape, size, pat_name)}

multi_pattern:
    |pat_lst=separated_nonempty_list(SEMICOLON, pattern)
        {pat_lst}

pattern:
    |pat=nonempty_list(atom)
        {pat}

atom:
    |STAR
        {Atom.Rest}
    |d=INTEGER
        {Atom.Beat d}

shape:
    |PARTIAL
        {BudGrammar.Partial}
    |FULL
        {BudGrammar.Full}
    |COLORED
        {BudGrammar.Colored}

