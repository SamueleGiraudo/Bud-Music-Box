(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020
 *)

%token SEMICOLON
%token STAR

%token HELP
%token QUIT
%token SHOW
%token WRITE
%token PLAY
%token SET_SCALE
%token SET_ROOT
%token SET_TEMPO
%token SET_SOUNDS
%token MULTI_PATTERN
%token TRANSPOSE
%token MIRROR
%token CONCATENATE



%token <int> INTEGER
%token <string> NAME

%token EOF

%start <Program.program> program

%%

program:
    |lst=list(instruction) EOF
        {lst}

instruction:
    |HELP
        {Program.Help}
    |QUIT
        {Program.Quit}
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
    |TRANSPOSE res_name=NAME mpat_name=NAME k=INTEGER
        {Program.Transpose (res_name, mpat_name, k)}
    |MIRROR res_name=NAME mpat_name=NAME
        {Program.Mirror (res_name, mpat_name)}
    |CONCATENATE res_name=NAME mpat_names_lst=nonempty_list(NAME)
        {Program.Concatenate (res_name, mpat_names_lst)}




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




