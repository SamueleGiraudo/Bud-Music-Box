(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, dec. 2019, jan. 2020, apr. 2020, oct. 2020
 *)

(* An exception raised in functions called with wrong arguments. *)
exception BadValue

(* An exception raised in function taking at input strings to convert them when these
 * string have a wrong format. *)
exception BadStringFormat

exception SyntaxError of string
exception ArgumentError of string
exception Error of string

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

(* Returns the index of the i-th element of the list lst satisfying the predicate pred.
 * Raises Not_found when there is no such element in lst. *)
let rec index_ith_occurrence lst pred i =
    match lst with
        |[] -> raise Not_found
        |x :: _ when (pred x) && i = 1 -> 0
        |x :: lst' when pred x -> 1 + (index_ith_occurrence lst' pred (i - 1))
        |_ :: lst' -> 1 + (index_ith_occurrence lst' pred i)

(* Returns the positions of the elements of the list lst that satisfy the predicate pred. *)
let positions_satisfying pred lst =
    let lst' = List.combine (interval 0 ((List.length lst) - 1)) lst in
    lst' |> List.fold_left
        (fun res (i, x) -> if pred x then i :: res else res)
        []

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

(* Returns the list made of the elements separated by the char sep in the string str, where
 * string_to_element is a map constructing an element from a string. Raises an
 * exception from the map string_to_element if a string has a wrong format. *)
let list_from_string string_to_element sep str =
    let tokens = String.split_on_char sep str |> List.filter (fun str -> str <> "") in
    tokens |> List.map string_to_element

(* Returns the string obtained by suppressing the first character of the string s. *)
let remove_first_char s =
    assert (s <> "");
    String.sub s 1 ((String.length s) - 1)

(* Returns the version of the string s obtained by remove spaces, tabs, and newline
 * characters. *)
let remove_blank_characters s =
    let preprocess = Str.split (Str.regexp "[ \t\n]+") s in
    String.concat "" preprocess

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

let argument_error name index_arg msg =
    let str = Printf.sprintf "the arg. %d of [%s] %s" index_arg name msg in
    raise (ArgumentError str)

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
            raise (Error str)
        end
        |ArgumentError msg -> begin
            let str = Printf.sprintf "Argument error in %s: %s\n" (position lexbuf) msg in
            raise (Error str)
        end
        |_ -> begin
            let str = Printf.sprintf "Error in %s\n" (position lexbuf) in
            raise (Error str)
        end

let value_from_file_path parser_axiom lexer_axiom path =
    assert (Sys.file_exists path);
    let lexbuf = Lexing.from_channel (open_in path) in
    lexbuf.Lexing.lex_curr_p <- {lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = path};
    parse_lexer_buffer parser_axiom lexer_axiom lexbuf

