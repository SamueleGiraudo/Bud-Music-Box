(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020, apr. 2021, jul. 2022, aug. 2022, nov. 2023
 *)

{

(* A type to communicate about parsing or lexing errors. *)
type error_information = {
    path: string;
    line: int;
    column: int;
    message: string
}

(* An exception raised when an error is encountered. *)
exception Error of error_information

(* Returns a string representation for the error information ei. *)
let error_information_to_string ei =
    let tmp = Printf.sprintf "in file %s at line %d and column %d"
        ei.path ei.line ei.column in
    if ei.message = "" then
        tmp
    else
        tmp ^ ": " ^ ei.message

(* Modifies the lexing buffer lexbuf so that it contains the next line. *)
let next_line lexbuf =
    let pos = lexbuf.Lexing.lex_curr_p in
    lexbuf.Lexing.lex_curr_p <-
        {pos with
            Lexing.pos_bol = lexbuf.Lexing.lex_curr_pos;
            Lexing.pos_lnum = pos.Lexing.pos_lnum + 1}

(* Returns an error information from the lexing buffer lexbuf and the string message. *)
let lexbuf_to_error_information lexbuf message =
    let pos = lexbuf.Lexing.lex_curr_p in
    {path = pos.Lexing.pos_fname;
     line = pos.Lexing.pos_lnum;
     column = pos.Lexing.pos_cnum - pos.Lexing.pos_bol + 1;
     message = message}

(* Raises Error with information about the unexpected character c. *)
let unexpected_character_error lexbuf c =
    let ei = lexbuf_to_error_information
        lexbuf (Printf.sprintf "unexpected character %c" c) in
    raise (Error ei)

(* Raises Error with information about an unclosed comment. *)
let unclosed_comment_error lexbuf =
    let ei = lexbuf_to_error_information lexbuf "unclosed comment" in
    raise (Error ei)

(* Returns the value computed by the parser parser_axiom, with the lexer lexer_axiom, and
 * with the buffer lexbuf. If there is an error, the exception Error is raised. *)
let parse_lexer_buffer parser_axiom lexer_axiom lexbuf =
    try
        parser_axiom lexer_axiom lexbuf
    with
        |Parser.Error ->
            let ei = lexbuf_to_error_information lexbuf "parsing error" in
            raise (Error ei)
        |Error ei ->
            let ei' = {ei with message = "lexing error: " ^ ei.message} in
            raise (Error ei')

(* Returns the value contained in the file at path path, interpreted with the parser
 * parser_axiom, with the lexer lexer_axiom. If an error is found, the exception Error is
 * raised. *)
let value_from_file_path path parser_axiom lexer_axiom =
    assert (Sys.file_exists path);
    let ch = open_in path in
    let str =  really_input_string ch (in_channel_length ch) in
    close_in ch;
    let lexbuf = Lexing.from_string str in
    lexbuf.Lexing.lex_curr_p <- {lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = path};
    parse_lexer_buffer parser_axiom lexer_axiom lexbuf

}

let letters = ['a'-'z' 'A'-'Z']
let digits = ['0'-'9']
let specials = ['_' ''']
let name = (letters | specials) (letters | specials | digits)*
let positive_integer = ['1'-'9'] digits*

rule read = parse
    |" " |"\t" {read lexbuf}
    |"\n" {next_line lexbuf; read lexbuf}
    |"0" {Parser.ZERO_INTEGER}
    |"-" {Parser.MINUS}
    |"+" {Parser.PLUS}
    |"." {Parser.DOT}
    |"%" {Parser.PERCENT}
    |"|" {Parser.PIPE}
    |"show" {Parser.SHOW}
    |"write" {Parser.WRITE}
    |"play" {Parser.PLAY}
    |"scale" {Parser.SCALE}
    |"root" {Parser.ROOT}
    |"tempo" {Parser.TEMPO}
    |"sounds" {Parser.SOUNDS}
    |"monoid" {Parser.MONOID}
    |"add" {Parser.ADD}
    |"cyclic" {Parser.CYCLIC}
    |"mul" {Parser.MUL}
    |"mul-mod" {Parser.MUL_MOD}
    |"max" {Parser.MAX}
    |"multi-pattern" {Parser.MULTI_PATTERN}
    |"mirror" {Parser.MIRROR}
    |"inverse" {Parser.INVERSE}
    |"concatenate" {Parser.CONCATENATE}
    |"repeat" {Parser.REPEAT}
    |"stack" {Parser.STACK}
    |"partial-compose" {Parser.PARTIAL_COMPOSE}
    |"full-compose" {Parser.FULL_COMPOSE}
    |"homogeneous-compose" {Parser.HOMOGENEOUS_COMPOSE}
    |"colorize" {Parser.COLORIZE}
    |"mono-colorize" {Parser.MONO_COLORIZE}
    |"generate" {Parser.GENERATE}
    |"partial" {Parser.PARTIAL}
    |"full" {Parser.FULL}
    |"homogeneous" {Parser.HOMOGENEOUS}
    |positive_integer {Parser.POSITIVE_INTEGER (int_of_string (Lexing.lexeme lexbuf))}
    |name {Parser.NAME (Lexing.lexeme lexbuf)}
    |"{" {comment 0 lexbuf}
    |eof {Parser.EOF}
    |_ as c {unexpected_character_error lexbuf c}

and comment level = parse
    |"\n" {next_line lexbuf; comment level lexbuf}
    |"}" {if level = 0 then read lexbuf else comment (level - 1) lexbuf}
    |"{" {comment (level + 1) lexbuf}
    |eof {unclosed_comment_error lexbuf}
    |_ {comment level lexbuf}

