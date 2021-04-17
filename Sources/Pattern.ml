(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019, sep. 2019, dec. 2019, jan. 2020,
 * apr. 2020, may 2020, oct. 2020, apr. 2021
 *)

(* A pattern is a nonempty list of atoms. *)
type pattern = Atom.atom list

(* Tests if p is a valid pattern. *)
let is_valid p =
    p <> []

(* Returns a string representing the pattern p. *)
let to_string p =
    assert (is_valid p);
    Tools.list_to_string Atom.to_string " " p

(* Returns the pattern consisting in unity atom, having degree 0. *)
let unity =
    [Atom.Beat 0]

(* Returns the pattern consisting in a sequence of k rests. *)
let rest k =
    assert (k >= 1);
    List.init k (fun _ -> Atom.Rest)

(* Returns the pattern consisting in an atom of degree d followed by k - 1 rests. This is in
 * fact a degree with k as duration. *)
let beat d k =
    assert (k >= 1);
    (Atom.Beat d) :: (rest (k - 1))

(* Returns the arity of the pattern p. This is the number of beats of the pattern. *)
let arity p =
    assert (is_valid p);
    p |> List.fold_left (fun res a -> if Atom.is_beat a then 1 + res else res) 0

(* Returns the length of the pattern p. This is the number of atoms of the pattern. *)
let length p =
    assert (is_valid p);
    List.length p

(* Returns the list of the degrees of the pattern p. *)
let degrees p =
    assert (is_valid p);
    p |> List.filter Atom.is_beat |> List.map Atom.get_degree

(* Returns the list of the durations of the beats of the pattern p. *)
let durations p =
    assert (is_valid p);
    let rec aux lst =
        match lst with
            |[] -> []
            |Atom.Rest :: lst' -> aux lst'
            |(Atom.Beat _) :: lst' -> (1 + (Tools.length_start lst' Atom.Rest)) :: aux lst'
    in
    aux p

(* Tests if all the atoms of the pattern p are on the degree monoid dm. *)
let is_on_degree_monoid dm p =
    assert (is_valid p);
    p |> List.for_all (Atom.is_on_degree_monoid dm)

(* Returns the pattern obtained by the partial composition of the patterns p1 and p2
 * at position i w.r.t. the degree monoid dm. *)
let rec partial_composition dm p1 i p2 =
    assert (is_valid p1);
    assert (is_valid p2);
    assert (is_on_degree_monoid dm p1);
    assert (is_on_degree_monoid dm p2);
    assert ((1 <= i) && (i <= arity p1));
    match p1, i with
        |(Atom.Beat _) as a :: p1', 1 ->
            let p2' = p2 |> List.map (fun a' -> Atom.product dm a a') in
            List.append p2' p1'
        |Atom.Rest :: p1', i -> Atom.Rest :: (partial_composition dm p1' i p2)
        |(Atom.Beat d) :: p1', i -> (Atom.Beat d) :: (partial_composition dm p1' (i - 1) p2)
        |[], _ -> []

(* Returns the pattern obtained by replacing each degree of the pattern p by its image by
 * the map f. *)
let map f p =
    assert (is_valid p);
    p |> List.map (Atom.map f)

(* Returns the mirror image of the pattern p. *)
let mirror p =
    assert (is_valid p);
    List.rev p

(* Returns the pattern obtained by concatenating the pattern p1 with the pattern p2. *)
let concatenate p1 p2 =
    assert (is_valid p1);
    assert (is_valid p2);
    List.append p1 p2

(* Returns the operad of patterns on the degree monoid dm. *)
let operad dm =
    Operad.create arity (partial_composition dm) unity

