(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, dec. 2019, jan. 2020
 *)

exception BadValue
exception BadStringFormat

(* Tests if the integer value x is different from 0.*)
let int_to_bool x =
    if x = 0 then
        false
    else
        true

(* Returns the list of integers from a to b. *)
let rec interval a b =
    List.init (b - a + 1) (fun x -> x + a);;

(* Returns the factor of the list lst starting at position start and having len as
 * length. *)
let rec factor_list lst start len =
    if len = 0 then
        []
    else if start = 0 then
        (List.hd lst) :: (factor_list (List.tl lst) 0 (len - 1))
    else
        factor_list (List.tl lst) (start - 1) len

(* Returns the list obtained by inserting the list lst_2 at position i in the list lst_1.
 * The numbering starts by 1. *)
let partial_composition_lists lst_1 i lst_2 =
    assert ((1 <= i) && (i <= List.length lst_1));
    List.flatten [factor_list lst_1 0 (i - 1) ;
        lst_2 ;
        factor_list lst_1 i ((List.length lst_1) - i)]

(* Returns the index of the ith element of the list lst satisfying the predicate pred. *)
let rec index_ith_occurrence lst pred i =
    match lst with
        |[] -> raise Not_found
        |x :: lst' when (pred x) && i = 1 -> 0
        |x :: lst' when pred x -> 1 + (index_ith_occurrence lst' pred (i - 1))
        |_ :: lst' -> 1 + (index_ith_occurrence lst' pred i)

(* Returns the positions of the elements of the list lst that satisfy the predicate pred. *)
let positions_satisfying pred lst =
    let lst' = List.combine (interval 0 ((List.length lst) - 1)) lst in
    lst' |> List.fold_left
        (fun res (i, x) ->
            if pred x then
                i :: res
            else
                res)
        []

(* Returns the number of elements a starting the list lst. *)
let rec length_start lst a =
    match lst with
        |x :: lst' when x = a -> 1 + length_start lst' a
        |_ -> 0

(* Returns an element of the list lst picked at random. *)
let pick_random lst =
    List.nth lst (Random.int (List.length lst))

let rec list_factor lst start len =
    match lst with
        |[] -> []
        |_ when len = 0 -> []
        |x :: lst' when start = 0 -> x :: (list_factor lst' 0 (len - 1))
        |_ :: lst' -> list_factor lst' (start - 1) len

(* Returns a string representing the list lst, where element_to_string is a map sending
 * each element to a string representing it, and sep is a separating string. *)
let list_to_string element_to_string sep lst =
    lst |> List.map element_to_string |> String.concat sep

(* Returns the list made of the elements separated by the char sep in the string str, where
 * string_to_element is a map constructing an element from a string. If a string does not
 * encode an element (the map string_to_element returns an exception), this does not appear
 * in the resulting list. *)
let list_from_string string_to_element sep str =
    let tokens = String.split_on_char sep str |> List.filter (fun str -> str <> "") in
    let res = tokens |> List.fold_left
        (fun res tk ->
            try
                let a = string_to_element tk in
                a :: res
            with
                |_ -> raise BadStringFormat)
        []
    in
    List.rev res

let remove_first_char s =
    String.sub s 1 ((String.length s) - 1)

(* Returns the version of the string s obtained by remove spaces, tabs, and newline
 * characters. *)
let remove_blank_characters s =
    let preprocess = Str.split (Str.regexp "[ \t\n]+") s in
    String.concat "" preprocess


(* The test function of the module. *)
let test () =
    print_string "Test Tools\n";
    true

