(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* Returns def if the optional value opt is None. Otherwise, returns the value carried by
 * opt. *)
let value def opt =
    match opt with
        |Some x -> x
        |None -> def

(* Returns None if the optional value opt is None. Otherwise, return an option of the image
 * by the map f of the value carried by opt. *)
let map f opt =
    match opt with
        |None -> None
        |Some x -> Some (f x)

(* Returns None if at least one of the two optional values opt1 and opt2 is None. Otherwise,
 * returns an option on the image by the map f of the values carried by opt1 and op2. *)
let map_2 f opt1 opt2 =
    match opt1, opt2 with
        |None, _ -> None
        |_, None -> None
        |Some x1, Some x2 -> Some (f x1 x2)

