(* Author: Samuele Giraudo
 * Creation: apr. 2021
 * Modifications: apr. 2021, aug. 2022, nov. 2023
 *)

(* A degree monoid is a monoid structure on degrees. Operads on (multi-)patterns are
 * parameterized by degree monoids. *)
type degree_monoids = {
    name: string;
    is_element: Degrees.degrees -> bool;
    product: Degrees.degrees -> Degrees.degrees -> Degrees.degrees;
    unity: Degrees.degrees
}

(* Returns the name of the degree monoid dm *)
let name dm =
    dm.name

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
    {
        name = "Z";
        is_element = Fun.const true;
        product = Degrees.operation (+);
        unity = Degrees.zero
    }

(* Returns the cyclic degree monoid of order k. *)
let cyclic k =
    assert (k >= 1);
    let is_element d =
        let v = Degrees.value d in
        0 <= v && v < k
    in
    let product = Degrees.operation (fun n1 n2 -> (n1 + n2) mod k) in
    {
        name = Printf.sprintf "Z_%d" k;
        is_element = is_element;
        product = product;
        unity = Degrees.zero
    }

(* Returns the multiplicative degree monoid. *)
let mul =
    {
        name = "Zx";
        is_element = Fun.const true;
        product = Degrees.operation ( * );
        unity = Degrees.Degree 1
    }

(* Returns the multiplicative modulo k degree monoid. *)
let mul_mod k =
    assert (k >= 1);
    let is_element d =
        let v = Degrees.value d in
        0 <= v && v < k
    in
    let product = Degrees.operation (fun n1 n2 -> (n1 * n2) mod k) in
    {
        name = Printf.sprintf "Zx_%d" k;
        is_element = is_element;
        product = product;
        unity = Degrees.Degree 1
    }

(* Returns the max degree monoid with z as minimal element. *)
let max z =
    let is_element d =
        z <= (Degrees.value d)
    in
    {
        name = (Printf.sprintf "M_%d" z);
        is_element = is_element;
        product = Degrees.operation max;
        unity = Degrees.Degree z
    }

