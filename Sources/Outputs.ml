(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* Prints the string str as an error. *)
let print_error str =
    "?? " ^ str |> Strings.csprintf Strings.Red |> print_string;
    flush stdout

(* Prints the string str as an information. *)
let print_information str =
    ">> " ^ str |> Strings.csprintf Strings.Blue |> print_string;
    flush stdout

(* Prints the string str as a success. *)
let print_success str =
    "!! " ^ str |> Strings.csprintf Strings.Green |> print_string;
    flush stdout

