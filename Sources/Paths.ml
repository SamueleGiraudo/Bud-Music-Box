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

(* Returns a path that does not correspond to any existing file by adding a string "_N"
 * just before the extension of the path path, where N is an adequate number. *)
let new_distinct path =
    let path' = remove_extension path and ext' = extension path in
    let rec aux i =
        let res_path = Printf.sprintf "%s_%d%s" path' i ext' in
        if Sys.file_exists res_path then
            aux (i + 1)
        else
            res_path
    in
    aux 0

