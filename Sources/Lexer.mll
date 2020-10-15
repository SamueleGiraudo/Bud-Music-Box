(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020
 *)

{

exception SyntaxError of string

let next_line lexbuf =
    let pos = lexbuf.Lexing.lex_curr_p in
    lexbuf.Lexing.lex_curr_p <-
        {pos with
            Lexing.pos_bol = lexbuf.Lexing.lex_curr_pos;
            Lexing.pos_lnum = pos.Lexing.pos_lnum + 1}

let unexpected_character_error c =
    raise (SyntaxError (Printf.sprintf "unexpected character %c" c))

let unclosed_comment_error () =
    raise (SyntaxError "unclosed comment")

let position lexbuf =
    let pos = lexbuf.Lexing.lex_curr_p in
    Printf.sprintf "file %s, line %d, column %d"
        pos.Lexing.pos_fname
        pos.Lexing.pos_lnum
        (pos.Lexing.pos_cnum - pos.Lexing.pos_bol + 1)

let parse_lexer_buffer parser_axiom lexer_axiom lexbuf =
    try
        parser_axiom lexer_axiom lexbuf
    with
        |SyntaxError msg -> begin
            let str = Printf.sprintf "Syntax error in %s: %s\n" (position lexbuf) msg in
            raise (SyntaxError str)
        end
        |_ ->
            let str = Printf.sprintf "Syntax error in %s\n" (position lexbuf) in
            raise (SyntaxError str)

let value_from_file_path parser_axiom lexer_axiom path =
    assert (Sys.file_exists path);
    let lexbuf = Lexing.from_channel (open_in path) in
    lexbuf.Lexing.lex_curr_p <- {lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = path};
    parse_lexer_buffer parser_axiom lexer_axiom lexbuf

let interpret_file_path path parser_axiom lexer_axiom execute error_test =
    try
        let t = value_from_file_path parser_axiom lexer_axiom path in
        if not (error_test t) then
            Printf.printf "There are errors in the program.\n"
        else begin
            Printf.printf "The program as no errors.\n";
            Printf.printf "Execution...\n";
            execute t;
            Printf.printf "End of execution.\n"
        end
    with
        |SyntaxError msg -> Printf.printf "Syntax error: %s\n" msg
        |Program.ExecutionError msg -> Printf.printf "Execution error: %s\n" msg

}

let letter = ['a'-'z' 'A'-'Z' '_']
let digits = ['0'-'9']
let plain_character = letter | digits

let name = letter plain_character*
let integer = '-'? digits+

rule read = parse
    |' ' |'\t'
        {read lexbuf}
    |'\n'
        {next_line lexbuf; read lexbuf}
    |';'
        {Parser.SEMICOLON}
    |'*'
        {Parser.STAR}
    |"show"
        {Parser.SHOW}
    |"write"
        {Parser.WRITE}
    |"play"
        {Parser.PLAY}
    |"set_scale"
        {Parser.SET_SCALE}
    |"set_root"
        {Parser.SET_ROOT}
    |"set_tempo"
        {Parser.SET_TEMPO}
    |"set_sounds"
        {Parser.SET_SOUNDS}
    |"multi_pattern"
        {Parser.MULTI_PATTERN}
    |"transpose"
        {Parser.TRANSPOSE}
    |"mirror"
        {Parser.MIRROR}
    |"concatenate"
        {Parser.CONCATENATE}
    |"repeat"
        {Parser.REPEAT}
    |"transform"
        {Parser.TRANSFORM}
    |"partial_compose"
        {Parser.PARTIAL_COMPOSE}
    |"full_compose"
        {Parser.FULL_COMPOSE}
    |"binarily_compose"
        {Parser.BINARILY_COMPOSE}
    |"colorize"
        {Parser.COLORIZE}
    |"generate"
        {Parser.GENERATE}
    |"partial"
        {Parser.PARTIAL}
    |"full"
        {Parser.FULL}
    |"colored"
        {Parser.COLORED}
    |"temporize"
        {Parser.TEMPORIZE}
    |"rhythmize"
        {Parser.RHYTHMIZE}
    |"harmonize"
        {Parser.HARMONIZE}
    |"arpeggiate"
        {Parser.ARPEGGIATE}
    |"mobiusate"
        {Parser.MOBIUSATE}
    |integer
        {Parser.INTEGER (int_of_string (Lexing.lexeme lexbuf))}
    |name
        {Parser.NAME (Lexing.lexeme lexbuf)}
    |'{'
        {comment 0 lexbuf}
    |eof
        {Parser.EOF}
    |_ as c
        {unexpected_character_error c}

and comment level = parse
    |'\n'
        {next_line lexbuf; comment level lexbuf}
    |'}'
        {if level = 0 then read lexbuf else comment (level - 1) lexbuf}
    |'{'
        {comment (level + 1) lexbuf}
    |eof
        {unclosed_comment_error ()}
    |_
        {comment level lexbuf}

