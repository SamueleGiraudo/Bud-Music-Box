(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* Returns the extension of the file at path path. *)
let extension path =
    let i = String.rindex path '.' in
    String.sub path i (String.length path - i)

(* Tests if the file at path path has the extension ext (with the point). *)
let has_extension ext path =
    if String.contains path '.' then extension path = ext else false

(* Returns the string obtained from the path path by removing its file extension, including
 * the '.'. *)
let remove_extension path =
    assert (String.contains path '.');
    let i = String.rindex path '.' in
    String.sub path 0 i

