(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, dec. 2019, jan. 2020, apr. 2020, oct. 2020
 *)

(* An exception raised in functions called with wrong arguments. *)
exception BadValue

exception SyntaxError of string
exception ExecutionError of string

(* Tests if the integer value x is different from 0.*)
let int_to_bool x =
    if x = 0 then
        false
    else
        true

(* Returns the list of integers from a to b. *)
let interval a b =
    List.init (b - a + 1) (fun x -> x + a);;

(* Returns the factor of the list lst starting at position start and of length len. *)
let rec list_factor lst start len =
    match lst with
        |[] -> []
        |_ when len = 0 -> []
        |x :: lst' when start = 0 -> x :: (list_factor lst' 0 (len - 1))
        |_ :: lst' -> list_factor lst' (start - 1) len

(* Returns the suffix of the list lst beginning at the index start. *)
let list_suffix lst start =
    list_factor lst start ((List.length lst) - start)

(* Returns the list obtained by inserting the list lst_2 at position i in the list lst_1.
 * The numbering starts by 1. *)
let partial_composition_lists lst_1 i lst_2 =
    assert ((1 <= i) && (i <= List.length lst_1));
    List.flatten [list_factor lst_1 0 (i - 1) ;
        lst_2 ;
        list_factor lst_1 i ((List.length lst_1) - i)]

(* Returns the number of elements a starting the list lst. *)
let rec length_start lst a =
    match lst with
        |x :: lst' when x = a -> 1 + length_start lst' a
        |_ -> 0

(* Returns an element of the list lst picked at random. *)
let pick_random lst =
    List.nth lst (Random.int (List.length lst))

(* Returns a string representing the list lst, where element_to_string is a map sending
 * each element to a string representing it, and sep is a separating string. *)
let list_to_string element_to_string sep lst =
    lst |> List.map element_to_string |> String.concat sep

(* Tests if the current execution environment admits the string arg as argument. *)
let has_argument arg =
    Array.mem arg Sys.argv

(* Returns an option of the argument following the argument arg of the current execution
 * environment. Returns None if arg is not an argument or if there is no argument following
 * it. *)
let next_argument arg =
    let len = Array.length Sys.argv in
    let tmp = List.init (len - 1) Fun.id |> List.find_opt (fun i -> Sys.argv.(i) = arg) in
    match tmp with
        |None -> None
        |Some i -> if i + 1 < len then Some Sys.argv.(i + 1) else None

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

let parse_lexer_buffer parser_axiom lexer_axiom lexbuf =
    let position lexbuf =
        let pos = lexbuf.Lexing.lex_curr_p in
        Printf.sprintf "file %s, line %d, column %d"
            pos.Lexing.pos_fname
            pos.Lexing.pos_lnum
            (pos.Lexing.pos_cnum - pos.Lexing.pos_bol + 1)
    in
    try
        parser_axiom lexer_axiom lexbuf
    with
        |SyntaxError msg -> begin
            let str = Printf.sprintf "Syntax error in %s: %s \n" (position lexbuf) msg in
            raise (SyntaxError str)
        end

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
        |SyntaxError msg -> begin
            Printf.printf "Errors:\n";
            Printf.printf "%s\n" msg
        end
        |ExecutionError msg -> begin
            Printf.printf "Execution errors:\n";
            Printf.printf "%s\n" msg
        end

