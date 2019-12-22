(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019, sep. 2019, dec. 2019
 *)

(* A pattern is a list of atoms. There is no condition: all lists are valid patterns, even
 * the empty list. *)
type pattern = Atom.atom list

(* Returns a string representing the pattern pat. *)
let to_string pat =
    Tools.list_to_string Atom.to_string " " pat

(* Returns the pattern encoded by the string str.
 * For instance, "* 1 * * * 2 -1 8 * 12 0" encodes a pattern, where the "*" are rests. Each
 * beat or rest must be separated by at least one space. *)
let from_string str =
    Tools.list_from_string Atom.from_string ' ' str

(* Returns the empty pattern. *)
let empty =
    []

(* Returns the pattern consisting in one atom, having degree 0. *)
let one =
    [Atom.Beat 0]

(* Returns the pattern consisting in one atom of degree deg followed by duration - 1 rests.
 * This is in fact a degree with duration as duration. *)
let beat deg duration =
    assert (duration >= 1);
    let rests = (Tools.interval 2 duration) |> List.map (fun _ -> Atom.Rest) in
    (Atom.Beat deg) :: rests

(* Returns the pattern consisting in a sequence of duration rests. *)
let rest duration =
    assert (duration >= 0);
    (Tools.interval 1 duration) |> List.map (fun _ -> Atom.Rest)

(* Returns the pattern obtained by concatenating the patterns of the list of patterns
 * pattern_lst. *)
let concat pattern_lst =
    List.concat pattern_lst

(* Returns the arity of the pattern pat. This is the number of beats of the pattern. *)
let arity pat =
    pat |> List.fold_left (fun res a -> if Atom.is_beat a then 1 + res else res) 0

(* Returns the length of the pattern pat. This is the number of atom of the pattern. *)
let length pat =
    List.length pat

(* Returns the list of the degrees of the pattern pat. *)
let extract_degrees pat =
    pat |> List.filter Atom.is_beat |> List.map Atom.get_degree

(* Returns the list of the durations of the beats of the pattern pat. *)
let extract_durations pat =
    let rec aux lst =
        match lst with
            |[] -> []
            |Atom.Rest :: lst' -> aux lst'
            |(Atom.Beat d) :: lst' -> (1 + (Tools.length_start lst' Rest)) :: aux lst'
    in
    aux pat

(* Returns the pattern obtained by the partial composition of the patterns pat_1 and pat_2
 * at position i. *)
let partial_composition pat_1 i pat_2 =
    assert ((1 <= i) && (i <= (arity pat_1)));
    let j = Tools.index_ith_occurrence pat_1 Atom.is_beat i in
    let d = Atom.get_degree (List.nth pat_1 j) in
    let pat_2' = pat_2 |> List.map (fun a -> Atom.incr a d) in
    Tools.partial_composition_lists pat_1 (j + 1) pat_2'

(* Returns the pattern obtained by multiplying by k each of its atoms. *)
let exterior_product pat k =
    pat |> List.map (fun a -> Atom.mul a k)

(* Returns the operad of patterns. *)
let operad =
    Operad.create arity partial_composition one


(* The test function of the module. *)
let test () =
    print_string "Test Pattern\n";
    true

