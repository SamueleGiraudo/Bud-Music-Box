(* Author: Samuele Giraudo
 * Creation: apr. 2021
 * Modifications: apr. 2021
 *)

(* A degree monoid is a monoid structure on degrees. Operads on (multi-)patterns are
 * parametrized by degree monoids. *)
type degree_monoid = {
    is_element : int -> bool;
    product : int -> int -> int;
    unity : int
}

let is_element dm =
    dm.is_element

let product dm x x' =
    assert (dm.is_element x);
    assert (dm.is_element x');
    dm.product x x'

let unity dm =
    dm.unity

let add_int =
    {is_element = (fun _ -> true); product = (+); unity = 0}

let cyclic k =
    assert (k >= 1);
    {is_element = (fun x -> 0 <= x && x < k);
        product = (fun x x' -> (x + x') mod k);
        unity = 0}

let max z =
    {is_element = (fun x -> z <= x); product = max; unity = z}

