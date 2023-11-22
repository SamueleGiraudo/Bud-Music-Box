(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019, dec. 2019, jan. 2020, apr. 2021,
 * aug. 2022, nov. 2023
 *)

(* An operad is specified by a map sending any of its elements to its arity, a partial
 * composition map, and a unit. *)
type 'a operads = {
    arity: 'a -> int;
    partial_composition: 'a -> int -> 'a -> 'a;
    unity: 'a
}

(* Returns the operad with the specified attributes. *)
let create arity partial_composition unity =
    {arity = arity; partial_composition = partial_composition; unity = unity}

(* Returns the unit of the operad op. *)
let unity op =
    op.unity

(* Returns the arity map of the operad op. *)
let arity op =
    op.arity

(* Returns the partial composition in the operad op of x and y at i-th position. *)
let partial_composition op x i y =
    assert ((1 <= i) && (i <= (op.arity x)));
    op.partial_composition x i y

(* Returns the full composition in the operad op of x and the list lst of elements. *)
let full_composition op x lst =
    assert ((op.arity x) = (List.length lst));
    let indexed_elements = lst |> List.mapi (fun i y -> (i + 1, y)) |> List.rev in
    indexed_elements |> List.fold_left (fun res (i, y) -> op.partial_composition res i y) x

(* Returns the homogeneous composition in the operad op of x and y. *)
let homogeneous_composition op x y =
    let ar = op.arity x in
    let lst = List.init ar (fun _ -> y) in
    full_composition op x lst

