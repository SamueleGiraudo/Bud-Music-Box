(* Author: Samuele Giraudo
 * Creation: apr. 2021
 * Modifications: apr. 2021, aug. 2022, nov. 2023
 *)

(* A degree monoid is a monoid structure on degrees. Operads on (multi-)patterns are
 * parameterized by degree monoids. *)
type degree_monoids = {
    is_element: Degrees.degrees -> bool;
    product: Degrees.degrees -> Degrees.degrees -> Degrees.degrees;
    unity: Degrees.degrees
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
let add =
    {is_element = Fun.const true; product = (Degrees.operation (+)); unity = Degrees.zero}

(* Returns the cyclic degree monoid of order k. *)
let cyclic k =
    assert (k >= 1);
    let is_element d =
        let v = Degrees.value d in
        0 <= v && v < k
    in
    let product = Degrees.operation (fun n1 n2 -> (n1 + n2) mod k) in
    {is_element = is_element; product = product; unity = Degrees.zero}

(* Returns the max degree monoid with z as minimal element. *)
let max z =
    let is_element d =
        z <= (Degrees.value d)
    in
    {is_element = is_element; product = (Degrees.operation max); unity = Degrees.Degree z}

