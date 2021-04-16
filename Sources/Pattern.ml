(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019, sep. 2019, dec. 2019, jan. 2020,
 * apr. 2020, may 2020, oct. 2020, apr. 2021
 *)

(* A pattern is a nonempty list of atoms. *)
type pattern = Atom.atom list

let is_valid pat =
    pat <> []

(* Returns a string representing the pattern pat. *)
let to_string pat =
    assert (is_valid pat);
    Tools.list_to_string Atom.to_string " " pat

(* Returns the pattern consisting in unity atom, having degree 0. *)
let unity =
    [Atom.Beat 0]

(* Returns the pattern consisting in a sequence of duration rests. *)
let rest duration =
    assert (duration >= 1);
    List.init duration (fun _ -> Atom.Rest)

(* Returns the pattern consisting in an atom of degree deg followed by duration - 1 rests.
 * This is in fact a degree with duration as duration. *)
let beat deg duration =
    assert (duration >= 1);
    (Atom.Beat deg) :: (rest (duration - 1))

(* Returns the arity of the pattern pat. This is the number of beats of the pattern. *)
let arity pat =
    assert (is_valid pat);
    pat |> List.fold_left (fun res a -> if Atom.is_beat a then 1 + res else res) 0

(* Returns the length of the pattern pat. This is the number of atom of the pattern. *)
let length pat =
    assert (is_valid pat);
    List.length pat

(* Returns the list of the degrees of the pattern pat. *)
let degrees pat =
    assert (is_valid pat);
    pat |> List.filter Atom.is_beat |> List.map Atom.get_degree

(* Returns the list of the durations of the beats of the pattern pat. *)
let durations pat =
    assert (is_valid pat);
    let rec aux lst =
        match lst with
            |[] -> []
            |Atom.Rest :: lst' -> aux lst'
            |(Atom.Beat _) :: lst' -> (1 + (Tools.length_start lst' Atom.Rest)) :: aux lst'
    in
    aux pat

(* Returns the pattern obtained by the partial composition of the patterns pat_1 and pat_2
 * at position i w.r.t. the degree monoid dm. *)
let rec partial_composition dm pat_1 i pat_2 =
    assert (is_valid pat_1);
    assert (is_valid pat_2);
    assert ((1 <= i) && (i <= arity pat_1));
    match pat_1, i with
        |(Atom.Beat _) as a :: pat_1', 1 ->
            let pat_2' = pat_2 |> List.map (fun a' -> Atom.product dm a a') in
            List.append pat_2' pat_1'
        |Atom.Rest :: pat_1', i -> Atom.Rest :: (partial_composition dm pat_1' i pat_2)
        |(Atom.Beat d) :: pat_1', i ->
            (Atom.Beat d) :: (partial_composition dm pat_1' (i - 1) pat_2)
        |[], _ -> []

(* Returns the pattern obtained by replacing each degree of the pattern pat by its image by
 * the map f. *)
let map f pat =
    assert (is_valid pat);
    pat |> List.map (Atom.map f)

(* Returns the pattern obtained by replacing each rest of the pattern pat by a sequence of
 * coeff rests. *)
(*
let dilatation coeff pat =
    assert (is_valid pat);
    assert (coeff >= 0);
    let rest_seq = rest coeff in
    let change a =
        match a with
            |Atom.Rest -> rest_seq
            |Atom.Beat _ -> [a]
    in
    pat |> List.map change |> List.flatten
*)

(* Returns the mirror image of the pattern pat. *)
let mirror pat =
    assert (is_valid pat);
    List.rev pat

(* Returns the pattern obtained by concatenating the pattern pat_1 with the pattern
 * pat_2. *)
let concatenate pat_1 pat_2 =
    assert (is_valid pat_1);
    assert (is_valid pat_2);
    List.append pat_1 pat_2

(* Returns the operad of patterns on the degree monoid dm. *)
let operad dm =
    Operad.create arity (partial_composition dm) unity

