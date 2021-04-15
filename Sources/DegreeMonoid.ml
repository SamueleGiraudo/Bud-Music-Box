(* Author: Samuele Giraudo
 * Creation: apr. 2021
 * Modifications: apr. 2021
*)

type degree_monoid = {
    product : int -> int -> int;
    unit : int
}

let product dm =
    dm.product

let unit dm =
    dm.unit

let add_int =
    {product = (+); unit = 0}

let cyclic k =
    assert (k >= 1);
    {product = (fun a b -> (a + b) mod k); unit = 0}

let max z =
    {product = max; unit = z}

