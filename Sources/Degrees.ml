(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* A degree is a (possibly negative) integer. *)
type degrees = Degree of int

(* Returns the value of the degree d. *)
let value d =
    let Degree n = d in
    n

(* Returns the degree of value 0. *)
let zero =
    Degree 0

(* Returns the string representation of the degree d. *)
let to_string d =
    d |> value |> string_of_int

(* Returns the degree obtained as the result of the application f on the value of the degree
 * d. *)
let map f d =
    Degree (d |> value |> f )

(* Returns the degree obtained as the result of the operation op on the values of the
 * degrees d1 and d2. *)
let operation op d1 d2 =
    Degree (op (value d1) (value d2))

(* Returns the opposite of the degree d. *)
let opposite d =
    d |> map (fun n -> -n)

