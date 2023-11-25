(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* A color is a name (string). *)
type colors = Color of string

(* Returns the name of the color c. *)
let name c =
    let Color name = c in
    name

(* Returns a string representation of the color c. *)
let to_string c =
    "%" ^ name c

