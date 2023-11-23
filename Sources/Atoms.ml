(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, dec. 2019, jan. 2020, may. 2020, oct. 2020,
 * jul. 2022, aug. 2022, nov. 2023
 *)

(* An atom is an indivisible element of a musical pattern. It can be a rest or a beat
 * attached with a degree. *)
type atoms =
    |Rest
    |Beat of Degrees.degrees

(* Returns a string representing the atom a. A rest is represented by a dot "." and a beat
 * is represented by the value of its degree in base ten. *)
let to_string a =
    match a with
        |Rest -> "."
        |Beat d -> Degrees.to_string d

(* Tests if the atom a is a beat. *)
let is_beat a =
    match a with
        |Rest -> false
        |Beat _ -> true

(* Returns Rest if the atom a is a rest and otherwise returns the atom having as degree the
 * image by f of the degree of a. *)
let map f a =
    match a with
        |Rest -> Rest
        |Beat d -> Beat (f d)

(* Tests if the atom a is a rest or if it is a beat having a degree in the degree monoid
 * dm. *)
let is_on_degree_monoid dm a =
    match a with
        |Rest -> true
        |Beat d -> DegreeMonoids.is_element dm d

