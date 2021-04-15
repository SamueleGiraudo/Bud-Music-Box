(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, dec. 2019, jan. 2020, may. 2020, oct. 2020
 *)

(* An atom is an indivisible element of a musical pattern. It can be a rest or a beat
 * attached with a degree. *)
type atom =
    |Rest
    |Beat of Scale.degree

(* Returns a string representing the atom a. A rest is represented by a star "*" and a beat
 * is represented by the value of its degree in base ten. *)
let to_string a =
    match a with
        |Rest -> "*"
        |Beat d -> string_of_int d

(* Tests if the atom a is a rest. *)
let is_rest a =
    match a with
        |Rest -> true
        |Beat _ -> false

(* Tests if the atom a is a beat. *)
let is_beat a =
    match a with
        |Rest -> false
        |Beat _ -> true

(* Returns the degree associated with the atom a. If a not a beat, the exception
 * Tools.BadValue is raised. *)
let get_degree a =
    match a with
        |Rest -> raise Tools.BadValue
        |Beat d -> d

(* Returns the atom obtained from the atom a by incrementing it by k if it is a beat. When a
 * is a rest, a is returned. *)
(* TODO: remove. *)
let incr a k =
    match a with
        |Rest -> Rest
        |Beat d -> Beat (d + k)

(* Returns the atom obtained from the atom a by multiplying it by k if it is a beat. When a
 * is a rest, a is returned. *)
(* TODO: remove. *)
let mul a k =
    match a with
        |Rest -> Rest
        |Beat d -> Beat (d * k)

let product dm a1 a2 =
    match a1, a2 with
        |Rest, Rest -> Rest
        |Rest, Beat _ -> Rest
        |Beat _, Rest -> Rest
        |Beat d1, Beat d2 -> Beat (DegreeMonoid.product dm d1 d2)

let map f a =
    match a with
        |Rest -> Rest
        |Beat d -> Beat (f d)

