(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, sep. 2019, dec. 2019, jan. 2020, apr. 2020, may 2020
 * oct. 2020, apr. 2021, jul. 2022, nov. 2023
 *)

(* A multi-pattern is a nonempty list of patterns such that all its patterns have the same
 * length and the same arity. *)
type multi_patterns = MultiPattern of Patterns.patterns list

(* A colored multi-pattern is a multi-pattern surrounded with an output color an input
 * colors. *)
type colored_multi_pattern = multi_patterns ColoredElements.colored_elements

(* Returns the list of the patterns forming the multi-pattern mp. *)
let patterns mp =
    let MultiPattern pats = mp in
    pats

(* Tests if the multi-pattern mpat is valid. *)
let is_valid mpat =
    match patterns mpat with
        |[] -> true
        |p :: lst' ->
            let len = Patterns.length p and ar = Patterns.arity p in
            lst' |> List.for_all
                (fun p' -> len = Patterns.length p' && ar = Patterns.arity p')

(* Returns the multi-pattern of multiplicity m obtained by stacking the pattern pat with m
 * copies of itself. *)
let from_pattern pat m =
    assert (m >= 1);
    MultiPattern (List.init m (fun _ -> pat))

(* Returns a string representing the multi-pattern mp. *)
let to_string mp =
    assert (is_valid mp);
    mp |> patterns |> Strings.from_list Patterns.to_string " + "

(* Returns the empty multi-pattern of multiplicity m. *)
let empty m =
    assert (m >= 1);
    MultiPattern (List.init m (Fun.const Patterns.empty))

(* Returns the multi-pattern consisting in m voices of the unity pattern. *)
let unity dm m =
    assert (m >= 1);
    MultiPattern (List.init m (Fun.const (Patterns.unity dm)))

(* Returns the arity of the multi-pattern mp. *)
let arity mp =
    assert (is_valid mp);
    mp |> patterns |> List.hd |> Patterns.arity

(* Returns the length of the multi-pattern mp. *)
let length mp =
    assert (is_valid mp);
    mp |> patterns |> List.hd |> Patterns.length

(* Returns the multiplicity of the multi-pattern mp. *)
let multiplicity mp =
    assert (is_valid mp);
    mp |> patterns |> List.length

(* Returns the i-th pattern of the multi-pattern mp. The indexation begins at 1. *)
let pattern mp i =
    assert (is_valid mp);
    assert ((1 <= i) && (i <= (multiplicity mp)));
    List.nth (patterns mp) (i - 1)

(* Tests if all the atoms of the multi-pattern mp are on the degree monoid dm. *)
let is_on_degree_monoid dm mp =
    assert (is_valid mp);
    mp |> patterns |> List.for_all (Patterns.is_on_degree_monoid dm)

(* Returns the multi-pattern obtained by the partial composition of the multi-patterns
 * mp1 and mp2 at position i w.r.t. the degree monoid dm. *)
let partial_composition dm mp1 i mp2 =
    assert (is_valid mp1);
    assert (is_valid mp2);
    assert (is_on_degree_monoid dm mp1);
    assert (is_on_degree_monoid dm mp2);
    assert ((multiplicity mp1) = (multiplicity mp2));
    assert ((1 <= i) && (i <= (arity mp1)));
    let pairs = List.combine (patterns mp1) (patterns mp2) in
    let pats =
        pairs
        |> List.map (fun (seq_1, seq_2) -> Patterns.partial_composition dm seq_1 i seq_2)
    in
    MultiPattern pats

(* Returns the multi-pattern obtained by replacing each degree of the multi-pattern mp by
 * its image by the map f. *)
let map f mp =
    assert (is_valid mp);
    MultiPattern (mp |> patterns |> List.map (Patterns.map f))

(* Returns the mirror image of the multi-pattern mp. *)
let mirror mp =
    assert (is_valid mp);
    MultiPattern (mp |> patterns |> List.map Patterns.mirror)

(* Returns the pattern obtained by concatenating the multi-pattern mp1 with the
 * multi-pattern mp. These multi-patterns must have the same multiplicity. *)
let concatenate mp1 mp2 =
    assert (is_valid mp1);
    assert (is_valid mp2);
    assert ((multiplicity mp1) = (multiplicity mp2));
    MultiPattern (List.map2 Patterns.concatenate (patterns mp1) (patterns mp2))

(* Returns the multi-pattern obtained by concatenating the multi-patterns of the list of
 * multi-patterns mp_lst. These multi-patterns must have the same multiplicity. *)
let concatenate_list mp_lst =
    assert (mp_lst <> []);
    assert (mp_lst |> List.for_all is_valid);
    assert (mp_lst |> List.for_all
        (fun mp -> multiplicity mp = multiplicity (List.hd mp_lst)));
    List.tl mp_lst |> List.fold_left concatenate (List.hd mp_lst)

(* Returns the multi-pattern obtained by stacking the two multi-patterns mp_1 and mp_2.
 * They must have the same arity and the same length. *)
let stack mp_1 mp_2 =
    assert (is_valid mp_1);
    assert (is_valid mp_2);
    assert (arity mp_1 = arity mp_2);
    assert (length mp_1 = length mp_2);
    MultiPattern (patterns mp_1 @ patterns mp_2)

(* Returns the multi-pattern obtained by stacking the multi-patterns of the list of
 * multi-patterns mp_lst. These multi-patterns must have the same arity and the same
 * length. *)
let stack_list mp_lst =
    assert (mp_lst <> []);
    assert (mp_lst |> List.for_all is_valid);
    assert (mp_lst |> List.for_all (fun mp -> arity mp = arity (List.hd mp_lst)));
    assert (mp_lst |> List.for_all (fun mp -> length mp = length (List.hd mp_lst)));
    mp_lst |> List.tl |> List.fold_left stack (List.hd mp_lst)

(* Returns the multi-pattern obtained by repeating k times the multi-pattern mpat. *)
let concatenate_repeat mp k =
    assert (is_valid mp);
    assert (k >= 1);
    concatenate_list (List.init k (Fun.const mp))

(* Returns the multi-pattern obtained by repeating ertically (by stacking) k times the
 * multi-pattern mpat. *)
let stack_repeat mp k =
    assert (is_valid mp);
    assert (k >= 1);
    let pats = patterns mp in
    MultiPattern (List.init k (Fun.const pats) |> List.flatten)

(* Returns the operad of multi-patterns of multiplicity m on the degree monoid dm. *)
let operad dm m =
    assert (m >= 1);
    Operads.make arity (partial_composition dm) (unity dm m)

(* Returns the multi-pattern obtained by the full composition of the multi-pattern mp with
 * the multi-pattern of the list mp_lst w.r.t. the degree monoid dm. *)
let full_composition dm mp mp_lst =
    assert (is_valid mp);
    assert (is_on_degree_monoid dm mp);
    assert (mp_lst |> List.for_all is_valid);
    assert (mp_lst |> List.for_all (is_on_degree_monoid dm));
    assert (mp_lst |> List.for_all
        (fun mp' -> (multiplicity mp) = (multiplicity mp')));
    let m = multiplicity mp in
    Operads.full_composition (operad dm m) mp mp_lst

(* Returns the multi-pattern obtained by the homogeneous composition of the multi-pattern
 * mp_1 with the multi-pattern mp_2. *)
let homogeneous_composition dm mp_1 mp_2 =
    assert (is_valid mp_1);
    assert (is_valid mp_2);
    assert (is_on_degree_monoid dm mp_1);
    assert (is_on_degree_monoid dm mp_2);
    assert ((multiplicity mp_1) = (multiplicity mp_2));
    let m = multiplicity mp_1 in
    Operads.homogeneous_composition (operad dm m) mp_1 mp_2

