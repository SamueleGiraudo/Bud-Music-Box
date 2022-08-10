(* Author: Samuele Giraudo
 * Creation: apr. 2021
 * Modifications: apr. 2021, aug. 2022
 *)

(* A degree monoid is a monoid structure on degrees. Operads on (multi-)patterns are
 * parametrized by degree monoids. *)
type degree_monoid = {
    is_element: int -> bool;
    product: int -> int -> int;
    unity: int
}

(* Returns a function testing if its argument is an element of the degree monoid dm. *)
let is_element dm =
    dm.is_element

(* Returns the element which is the product of x and x' in the degree monoid dm. *)
let product dm x x' =
    assert (dm.is_element x);
    assert (dm.is_element x');
    dm.product x x'

(* Returns the unity of the degree monoid dm. *)
let unity dm =
    dm.unity

(* Returns the additive degree monoid. *)
let add_int =
    {is_element = Fun.const true; product = (+); unity = 0}

(* Returns the cyclic degree monoid of order k. *)
let cyclic k =
    assert (k >= 1);
    {is_element = (fun x -> 0 <= x && x < k);
        product = (fun x x' -> (x + x') mod k);
        unity = 0}

(* Returns the max degree monoid with z as minimal element. *)
let max z =
    {is_element = (fun x -> z <= x); product = max; unity = z}

