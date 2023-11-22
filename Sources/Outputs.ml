(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* Prints the string str as an error. *)
let print_error str =
    str |> Strings.csprintf Strings.Red |> print_string;
    flush stdout

(* Prints the string str as an information. *)
let print_information_1 str =
    str |> Strings.csprintf Strings.Blue |> print_string;
    flush stdout

(* Prints the string str as an information. *)
let print_information_2 str =
    str |> Strings.csprintf Strings.Magenta |> print_string;
    flush stdout

(* Prints the string str as an information. *)
let print_information_3 str =
    str |> Strings.csprintf Strings.Yellow |> print_string;
    flush stdout

(* Prints the string str as a success. *)
let print_success str =
    str |> Strings.csprintf Strings.Green |> print_string;
    flush stdout

