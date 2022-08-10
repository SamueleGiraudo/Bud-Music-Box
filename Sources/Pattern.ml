(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019, sep. 2019, dec. 2019, jan. 2020,
 * apr. 2020, may 2020, oct. 2020, apr. 2021, jul. 2022
 *)

(* A pattern is a nonempty list of atoms. *)
type pattern = Atom.atom list

(* Returns a string representing the pattern p. *)
let to_string p =
    Tools.list_to_string Atom.to_string " " p

(* Returns the empty pattern. *)
let empty =
    []

(* Returns the pattern consisting in unity atom, having degree 0. *)
let unity dm =
    [Atom.Beat (DegreeMonoid.unity dm)]

(* Returns the pattern consisting in a sequence of k rests. *)
let rest k =
    assert (k >= 1);
    List.init k (Fun.const Atom.Rest)

(* Returns the pattern consisting in an atom of degree d followed by k - 1 rests. This is in
 * fact a degree with k as duration. *)
let beat d k =
    assert (k >= 1);
    (Atom.Beat d) :: (rest (k - 1))

(* Returns the arity of the pattern p. This is the number of beats of the pattern. *)
let arity p =
    p |> List.fold_left (fun res a -> if Atom.is_beat a then 1 + res else res) 0

(* Returns the length of the pattern p. This is the number of atoms of the pattern. *)
let length p =
    List.length p

(* Returns the list of the degrees of the pattern p. *)
let degrees p =
    p |> List.filter Atom.is_beat |> List.map Atom.get_degree

(* Tests if all the atoms of the pattern p are on the degree monoid dm. *)
let is_on_degree_monoid dm p =
    p |> List.for_all (Atom.is_on_degree_monoid dm)

(* Returns the pattern obtained by replacing each degree of the pattern p by its image by
 * the map f. *)
let map f p =
    p |> List.map (Atom.map f)

(* Returns the pattern obtained by the partial composition of the patterns p1 and p2
 * at position i w.r.t. the degree monoid dm. *)
let rec partial_composition dm p1 i p2 =
    assert (is_on_degree_monoid dm p1);
    assert (is_on_degree_monoid dm p2);
    assert ((1 <= i) && (i <= arity p1));
    match p1, i with
        |Atom.Beat d :: p1', 1 -> List.append (map (DegreeMonoid.product dm d) p2) p1'
        |Atom.Rest :: p1', i -> Atom.Rest :: partial_composition dm p1' i p2
        |Atom.Beat d :: p1', i -> Atom.Beat d :: partial_composition dm p1' (i - 1) p2
        |[], _ -> empty

(* Returns the mirror image of the pattern p. *)
let mirror p =
    List.rev p

(* Returns the pattern obtained by concatenating the pattern p1 with the pattern p2. *)
let concatenate p1 p2 =
    List.append p1 p2

(* Returns the operad of patterns on the degree monoid dm. *)
let operad dm =
    Operad.create arity (partial_composition dm) (unity dm)

