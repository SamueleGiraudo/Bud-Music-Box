(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, dec. 2019, jan. 2020, apr. 2020, oct. 2020,
 * apr. 2021, jul. 2022
 *)

(* About lists. *)

(* Returns the list of integers from a to b. *)
let interval a b =
    assert (a <= b);
    List.init (b - a + 1) (fun x -> x + a);;

(* Returns the prefix of length n of the list lst. *)
let rec prefix_list lst n =
    match lst, n with
        |_, n when n <= 0 -> []
        |[], _ -> []
        |x :: lst', n -> x :: (prefix_list lst' (n - 1))

(* Returns the factor of the list lst starting at position start and of length len. *)
let rec list_factor lst start len =
    match lst with
        |[] -> []
        |_ when len = 0 -> []
        |x :: lst' when start = 0 -> x :: (list_factor lst' 0 (len - 1))
        |_ :: lst' -> list_factor lst' (start - 1) len

(* Returns the list obtained by inserting the list lst_2 at position i in the list lst_1.
 * The numbering starts by 1. *)
let partial_composition_lists lst_1 i lst_2 =
    assert ((1 <= i) && (i <= List.length lst_1));
    List.flatten [list_factor lst_1 0 (i - 1) ;
        lst_2 ;
        list_factor lst_1 i ((List.length lst_1) - i)]

(* Returns an element of the list lst picked at random. *)
let pick_random lst =
    List.nth lst (Random.int (List.length lst))

(* Returns a string representing the list lst, where element_to_string is a map sending
 * each element to a string representing it, and sep is a separating string. *)
let list_to_string element_to_string sep lst =
    lst |> List.map element_to_string |> String.concat sep


(* About characters and strings. *)

(* Returns the string obtained by indenting each line of the string str by k spaces. *)
let indent k str =
    assert (k >= 0);
    let ind = String.make k ' ' in
    str |> String.fold_left
        (fun (res, c') c ->
            let s = String.make 1 c in
            if c' = Some '\n' then (res ^ ind ^ s, Some c) else (res ^ s, Some c))
        (ind, None)
        |> fst

(* Tests if the character c is an alphabetic character. *)
let is_alpha_character c =
    ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z')

(* Tests if the character c is a character allowed in aliases. *)
let is_plain_character c =
     (is_alpha_character c) || ('0' <= c && c <= '9') || c = '_'


(* About strings representing paths. *)

(* Returns the extension of the file at path path. *)
let extension path =
    let i = String.rindex path '.' in
    String.sub path i ((String.length path) - i)

(* Tests if the file at path path has the extension ext (with the point). *)
let has_extension ext path =
    if not (String.contains path '.') then
        false
    else
        extension path = ext


(* About program arguments. *)

(* Tests if the current execution environment admits the string arg as argument. *)
let has_argument arg =
    Array.mem arg Sys.argv

(* Returns the list of at most the nb arguments following the argument arg in the current
 * execution environment. The list can be shorten than nb if there are less that nb such
 * arguments. The list is empty if arg is not an argument of the correct execution
 * environment. *)
let next_arguments arg nb =
    assert (nb >= 1);
    let len = Array.length Sys.argv in
    let args = List.init (len - 1) (fun i -> Sys.argv.(i + 1)) in
    let rec search_suffix args =
        match args with
            |[] -> []
            |x :: args' when x = arg -> args'
            |_ :: args' -> search_suffix args'
    in
    prefix_list (search_suffix args) nb


(* About colors and inputs/outputs. *)

(* Representation of the 8 terminal colors in order to specify colored text to print. *)
type color =
    |Black
    |Red
    |Green
    |Yellow
    |Blue
    |Magenta
    |Cyan
    |White

(* Returns the code for each color corresponding to the coloration code in the terminal. *)
let color_code col =
    match col with
        |Black -> 90
        |Red -> 91
        |Green -> 92
        |Yellow -> 93
        |Blue -> 94
        |Magenta -> 95
        |Cyan -> 96
        |White -> 97

(* Returns the coloration of the string str by the color specified by the color col. *)
let csprintf col str =
    Printf.sprintf "\027[%dm%s\027[39m" (color_code col) str

(* Prints the string str as an error. *)
let print_error str =
    print_string (csprintf Red str);
    print_newline ()

(* Prints the string str as an information. *)
let print_information str =
    print_string (csprintf Blue str);
    print_newline ()

(* Prints the string str as a success. *)
let print_success str =
    print_string (csprintf Green str);
    print_newline ()

(* Returns a time stamp of the form 2021-04-17-15:52:19. *)
let time_string () =
    let t = Unix.localtime (Unix.gettimeofday ()) in
    Printf.sprintf "%d-%02d-%02d-%d:%d:%d"
        (1900 + t.Unix.tm_year) (t.Unix.tm_mon + 1) t.Unix.tm_mday t.Unix.tm_hour
        t.Unix.tm_min t.Unix.tm_sec

