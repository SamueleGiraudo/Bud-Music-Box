(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019, dec. 2019
 *)

(* An operad is specified by a map sending any of its elements to its arity, a partial
 * composition map, and a unit. *)
type 'a operad = {
    arity : 'a -> int;
    partial_composition : 'a -> int -> 'a -> 'a;
    one : 'a
}

(* Returns the operad with the specified attributes. *)
let create arity partial_composition one =
    {arity = arity;
    partial_composition = partial_composition;
    one = one}

(* Returns the unit of the operad op. *)
let one op =
    op.one

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
    let indexes = Tools.interval 1 (op.arity x) |> List.rev in
    let indexed_elements = List.combine indexes lst in
    indexed_elements |> List.fold_left (fun res (i, y) -> op.partial_composition res i y) x

(* Returns the binary composition in the operad op of x and y. *)
let binary_composition op x y =
    let ar = op.arity x in
    let lst = (Tools.interval 1 ar) |> List.map (fun _ -> y) in
    full_composition op x lst


(* The test function of the module. *)
let test () =
    print_string "Test Operad\n";
    true

