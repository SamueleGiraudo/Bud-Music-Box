(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, sep. 2019, dec. 2019, jan. 2020, apr. 2020, may 2020
 * oct. 2020, apr. 2021
 *)

(* A multi-pattern is a nonempty list of patterns such that all its patterns have the same
 * length and the same arity. *)
type multi_pattern = Pattern.pattern list

(* A colored multi-pattern is a multi-pattern surrounded with an output color an input
 * colors. *)
type colored_multi_pattern =
    multi_pattern BudGrammar.colored_element

(* Tests if the list lst of patterns is a multi-pattern. *)
let is_multi_pattern lst =
    if lst = [] then
        false
    else
        let len = Pattern.length (List.hd lst) and ar = Pattern.arity (List.hd lst) in
        lst |> List.for_all (fun p -> Pattern.length p = len && Pattern.arity p = ar)

(* Returns the multi-pattern of multiplicity m obtained by stacking the pattern pat with m
 * copies of itself. *)
let from_pattern pat m =
    assert (Pattern.is_valid pat);
    assert (m >= 1);
    List.init m (fun _ -> pat)

(* Returns a string representing the multi-pattern mpat. *)
let to_string mpat =
    assert (is_multi_pattern mpat);
    Tools.list_to_string Pattern.to_string " ; " mpat

(* Returns the multi-pattern consisting in m voices of the unity pattern. *)
let unity m =
    assert (m >= 1);
    List.init m (fun _ -> Pattern.unity)

(* Returns the arity of the multi-pattern mpat. *)
let arity mpat =
    assert (is_multi_pattern mpat);
    Pattern.arity (List.hd mpat)

(* Returns the length of the multi-pattern mpat. *)
let length mpat =
    assert (is_multi_pattern mpat);
    Pattern.length (List.hd mpat)

(* Returns the multiplicity of the multi-pattern mpat. *)
let multiplicity mpat =
    assert (is_multi_pattern mpat);
    List.length mpat

(* Returns the i-th pattern of the multi-pattern mpat. The indexation begins at 1. *)
let pattern mpat i =
    assert (is_multi_pattern mpat);
    assert ((1 <= i) && (i <= (multiplicity mpat)));
    List.nth mpat (i - 1)

(* Returns the multi-pattern obtained by the partial composition of the multi-patterns
 * mpat_1 and mpat_2 at position i w.r.t. the degree monoid dm. *)
let partial_composition dm mpat_1 i mpat_2 =
    assert (is_multi_pattern mpat_1);
    assert (is_multi_pattern mpat_2);
    assert ((multiplicity mpat_1) = (multiplicity mpat_2));
    assert ((1 <= i) && (i <= (arity mpat_1)));
    let pairs = List.combine mpat_1 mpat_2 in
    pairs |> List.map (fun (seq_1, seq_2) -> Pattern.partial_composition dm seq_1 i seq_2)

(* Returns the multi-pattern obtained by replacing each degree of the multi-pattern pat by
 * its image by the map f. *)
let map f mpat =
    assert (is_multi_pattern mpat);
    mpat |> List.map (Pattern.map f)

(* Returns the pattern obtained by replacing each rest of the multi-pattern mpat by a
 * sequence of coeff rests. *)
(*
let dilatation coeff mpat =
    assert (is_multi_pattern mpat);
    assert (coeff >= 0);
    mpat |> List.map (Pattern.dilatation coeff)
*)

(* Returns the mirror image of the multi-pattern mpat. *)
let mirror mpat =
    assert (is_multi_pattern mpat);
    mpat |> List.map Pattern.mirror

(* Returns the pattern obtained by concatenating the multi-pattern mpat_1 with the
 * multi-pattern mpat_2. These multi-patterns must have the same multiplicity. *)
let concatenate mpat_1 mpat_2 =
    assert (is_multi_pattern mpat_1);
    assert (is_multi_pattern mpat_2);
    assert ((multiplicity mpat_1) = (multiplicity mpat_2));
    List.map2 Pattern.concatenate mpat_1 mpat_2

(* Returns the multi-pattern obtained by concatenating the multi-patterns of the list of
 * multi-patterns mpat_lst. These multi-patterns must have the same multiplicity. *)
let concatenate_list mpat_lst =
    assert (mpat_lst <> []);
    assert (mpat_lst |> List.for_all is_multi_pattern);
    assert (mpat_lst |> List.for_all
        (fun mpat -> multiplicity mpat = multiplicity (List.hd mpat_lst)));
    List.tl mpat_lst |> List.fold_left concatenate (List.hd mpat_lst)

(* Returns the multi-pattern obtained by stacking the two multi-patterns mpat_1 and mpat_2.
 * They must have the same arity and the same length. *)
let stack mpat_1 mpat_2 =
    assert (is_multi_pattern mpat_1);
    assert (is_multi_pattern mpat_2);
    assert (arity mpat_1 = arity mpat_2);
    assert (length mpat_1 = length mpat_2);
    List.append mpat_1 mpat_2

(* TODO *)
let stack_list mpat_lst =
    assert (mpat_lst <> []);
    assert (mpat_lst |> List.for_all is_multi_pattern);
    assert (mpat_lst |> List.for_all (fun mpat -> arity mpat = arity (List.hd mpat_lst)));
    assert (mpat_lst |> List.for_all (fun mpat -> length mpat = length (List.hd mpat_lst)));
    List.concat mpat_lst

(* Returns the multi-pattern obtained by repeating k times the multi-pattern mpat. *)
let repeat mpat k =
    assert (is_multi_pattern mpat);
    assert (k >= 1);
    concatenate_list (List.init k (fun _ -> mpat))

(* Returns the m-multi-pattern, where m is the arity of the degree pattern deg_pattern
 * obtained by forming a chord from the degrees of deg_pattern. This produces a
 * multi-pattern of length 1 and or arity 1. For instance, for deg_pattern = 0 2 4, the
 * function returns the 3-multi-pattern 0 ; 2 ; 4. *)
let chord deg_pattern =
    assert (deg_pattern <> []);
    assert (deg_pattern |> List.for_all Atom.is_beat);
    deg_pattern |> List.map (fun b -> [b])

(* Returns the m-multi-pattern, where m is the length of the degree pattern deg_pattern
 * obtained by arpeggiating the degrees of deg_pattern. This produces a multi-pattern of
 * length m and of arity 1. For instance, for deg_pattern = 0 2 4, the function returns the
 * 3-multi-pattern 0 * * ; * 2 * ; * * 4. *)
let arpeggio deg_pattern =
    assert (deg_pattern <> []);
    assert (deg_pattern |> List.for_all Atom.is_beat);
    let len = List.length deg_pattern in
    let pairs = List.combine (Tools.interval 0 (len - 1)) deg_pattern in
    pairs |> List.map
        (fun (i, d) -> List.init len (fun j -> if j = i then d else Atom.Rest))

(* Returns the operad of multi-patterns of multiplicity m on the degree monoid dm. *)
let operad dm m =
    assert (m >= 1);
    Operad.create arity (partial_composition dm) (unity m)

(* Returns the multi-pattern obtained by the full composition of the multi-pattern mpat
 * with the multi-pattern of the list mpat_lst w.r.t. the degree monoid dm. *)
let full_composition dm mpat mpat_lst =
    assert (is_multi_pattern mpat);
    assert (mpat_lst |> List.for_all is_multi_pattern);
    assert (mpat_lst |> List.for_all
        (fun mpat' -> (multiplicity mpat) = (multiplicity mpat')));
    let m = multiplicity mpat in
    Operad.full_composition (operad dm m) mpat mpat_lst

(* Returns the multi-pattern obtained by the homogeneous composition of the multi-pattern
 * mpat_1 with the multi-pattern mpat_2. *)
let homogeneous_composition dm mpat_1 mpat_2 =
    assert (is_multi_pattern mpat_1);
    assert (is_multi_pattern mpat_2);
    assert ((multiplicity mpat_1) = (multiplicity mpat_2));
    let m = multiplicity mpat_1 in
    Operad.binary_composition (operad dm m) mpat_1 mpat_2

