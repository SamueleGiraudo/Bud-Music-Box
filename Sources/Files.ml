(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* Returns the extension of the file containing commands for the generation. *)
let extension = ".bmb"

(* Tests if the file at path path has the extension ext (with the point). *)
let has_right_extension path =
    let ext =
        let i = String.rindex path '.' in
        String.sub path i (String.length path - i)
    in
    if String.contains path '.' then ext = extension else false

(* Tests if the character c is an alphabetic character. *)
let is_alpha_character c =
    ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z')

(* Tests if the character c is a character allowed in aliases. *)
let is_plain_character c =
     (is_alpha_character c) || ('0' <= c && c <= '9') || c = '_'


