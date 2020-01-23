(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, dec. 2019, jan. 2020
 *)

(* An atom is an indivisible element of a musical pattern. It can be a rest or a beat
 * attached with a degree. *)
type atom =
    |Rest
    |Beat of Scale.degree

(* Returns a string representing the atom a. A rest is represented by a start "*" and a beat
 * is represented by the value of its degree in base ten. *)
let to_string a =
    match a with
        |Rest -> "*"
        |Beat d -> string_of_int d

(* Returns the atom encoded by the string str. Raises Tools.BadStringFormat if str does not
 * encode an atom. For instance, "*" encodes a rest and "6" encodes the beat having 6 as
 * degree.  *)
let from_string str =
    if str = "*" then
        Rest
    else
        try
            Beat (int_of_string str)
        with
            |Failure _ -> raise Tools.BadStringFormat

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

(* Returns the degree associated with the atom a. If a not a beat, the exception Failure is
 * raised. *)
let get_degree a =
    match a with
        |Rest -> raise Tools.BadValue
        |Beat a -> a

(* Returns the atom obtained from the atom a by incrementing it by k if it is a beat. When a
 * is a rest, a is returned. *)
let incr a k =
    match a with
        |Rest -> Rest
        |Beat d -> Beat (d + k)

(* Returns the atom obtained from the atom a by multiplying it by k if it is a beat. When a
 * is a rest, a is returned. *)
let mul a k =
    match a with
        |Rest -> Rest
        |Beat d -> Beat (d * k)


(* The test function of the module. *)
let test () =
    print_string "Test Atom\n";
    true

