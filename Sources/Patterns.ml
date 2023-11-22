(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019, sep. 2019, dec. 2019, jan. 2020,
 * apr. 2020, may 2020, oct. 2020, apr. 2021, jul. 2022, nov. 2023
 *)

(* A pattern is a nonempty list of atoms. *)
type patterns = Atoms.atoms list

(* Returns a string representing the pattern p. *)
let to_string p =
    Strings.from_list Atoms.to_string " " p

(* Returns the empty pattern. *)
let empty =
    []

(* Returns the pattern consisting in unity atom, having degree 0. *)
let unity dm =
    [Atoms.Beat (DegreeMonoids.unity dm)]

(* Returns the pattern consisting in a sequence of k rests. *)
let rest k =
    assert (k >= 1);
    List.init k (Fun.const Atoms.Rest)

(* Returns the pattern consisting in an atom of degree d followed by k - 1 rests. This is in
 * fact a degree with k as duration. *)
let beat d k =
    assert (k >= 1);
    (Atoms.Beat d) :: (rest (k - 1))

(* Returns the arity of the pattern p. This is the number of beats of the pattern. *)
let arity p =
    p |> List.fold_left (fun res a -> if Atoms.is_beat a then 1 + res else res) 0

(* Returns the length of the pattern p. This is the number of atoms of the pattern. *)
let length p =
    List.length p

(* Tests if all the atoms of the pattern p are on the degree monoid dm. *)
let is_on_degree_monoid dm p =
    p |> List.for_all (Atoms.is_on_degree_monoid dm)

(* Returns the pattern obtained by replacing each degree of the pattern p by its image by
 * the map f. *)
let map f p =
    p |> List.map (Atoms.map f)

(* Returns the pattern obtained by the partial composition of the patterns p1 and p2
 * at position i w.r.t. the degree monoid dm. *)
let rec partial_composition dm p1 i p2 =
    assert (is_on_degree_monoid dm p1);
    assert (is_on_degree_monoid dm p2);
    assert ((1 <= i) && (i <= arity p1));
    match p1, i with
        |Atoms.Beat d :: p1', 1 -> List.append (map (DegreeMonoids.product dm d) p2) p1'
        |Atoms.Rest :: p1', i -> Atoms.Rest :: partial_composition dm p1' i p2
        |Atoms.Beat d :: p1', i -> Atoms.Beat d :: partial_composition dm p1' (i - 1) p2
        |[], _ -> empty

(* Returns the mirror image of the pattern p. *)
let mirror p =
    List.rev p

(* Returns the pattern obtained by concatenating the pattern p1 with the pattern p2. *)
let concatenate p1 p2 =
    List.append p1 p2

(* Returns the operad of patterns on the degree monoid dm. *)
let operad dm =
    Operads.create arity (partial_composition dm) (unity dm)

