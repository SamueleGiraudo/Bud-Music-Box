(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, sep. 2019, dec. 2019
 *)

(* A multi-pattern is a nonempty list of patterns such that all its patterns have the same
 * length and the same arity. *)
type multi_pattern = Pattern.pattern list

(* A colored multi-pattern is a multi-pattern surrounded with an output color an input
 * colors. *)
type colored_pattern =
    multi_pattern BudGrammar.colored_element

(* Tests if the list lst of patterns is a multi-pattern. *)
let is_multi_pattern lst =
    if lst = [] then
        false
    else
        let pat = List.hd lst in
        let len = Pattern.length pat and ar = Pattern.arity pat in
        lst |> List.for_all (fun p -> Pattern.length p = len && Pattern.arity p = ar)

(* Returns a string representing the multi-pattern mpat. *)
let to_string mpat =
    assert (is_multi_pattern mpat);
    Tools.list_to_string (Pattern.to_string) " ; " mpat

(* Returns the multi-pattern encoded by the string str.
 * For instance, "* 1 * 2 ; * * 0 -1" is a 2-multi-pattern. *)
let from_string str =
    Tools.list_from_string Pattern.from_string ';' str

(* Returns the k-multi-pattern consisting in k voices of the empty pattern. *)
let empty k =
    assert (k >= 1);
    Tools.interval 1 k |> List.map (fun _ -> Pattern.empty)

(* Returns the k-multi-pattern consisting in k voices of the unit pattern. *)
let one k =
    assert (k >= 1);
    Tools.interval 1 k |> List.map (fun _ -> Pattern.one)

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
 * mpat_1 and mpat_2 at position i. *)
let partial_composition mpat_1 i mpat_2 =
    assert (is_multi_pattern mpat_1);
    assert (is_multi_pattern mpat_2);
    assert ((multiplicity mpat_1) = (multiplicity mpat_2));
    assert ((1 <= i) && (i <= (arity mpat_1)));
    let pairs = List.combine mpat_1 mpat_2 in
    pairs |> List.map (fun (seq_1, seq_2) -> Pattern.partial_composition seq_1 i seq_2)

(* Returns the multi-pattern obtained by multiplying each pattern of the multi-pattern mpat
 * by the corresponding element of the list of integers k_lst. *)
let exterior_product mpat k_lst =
    assert ((multiplicity mpat) = List.length k_lst);
    List.map2 (fun pat k -> Pattern.exterior_product pat k) mpat k_lst

(* Returns the operad of multi-patterns of multiplicity k. *)
let operad k =
    assert (k >= 1);
    Operad.create arity partial_composition (one k)


(* The test function of the module. *)
let test () =
    print_string "Test MultiPattern\n";
    true

