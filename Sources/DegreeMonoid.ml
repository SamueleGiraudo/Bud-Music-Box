(* Author: Samuele Giraudo
 * Creation: apr. 2021
 * Modifications: apr. 2021
*)

(* A degree monoid is a monoid structure on degrees. Operads on (multi-)patterns are
 * parametrized by degree monoids. *)
type degree_monoid = {
    product : int -> int -> int;
    unity : int
}

let product dm =
    dm.product

let unity dm =
    dm.unity

let add_int =
    {product = (+); unity = 0}

let cyclic k =
    assert (k >= 1);
    let product a b =
        assert (0 <= a && a < k);
        assert (0 <= b && b < k);
        (a + b) mod k
    in
    {product = product; unity = 0}

let max z =
    let product a b =
        assert (z <= a);
        assert (z <= b);
        max a b
    in
    {product = product; unity = z}

