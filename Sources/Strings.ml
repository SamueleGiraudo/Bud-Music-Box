(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

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

(* Returns a string representing the list lst, where element_to_string is a map sending
 * each element to a string representing it, and sep is a separating string. *)
let from_list element_to_string sep lst =
    lst |> List.map element_to_string |> String.concat sep

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

