(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* A colored multi-pattern is a multi-pattern surrounded with an output color an input
 * colors. *)
type colored_multi_patterns =
    ColoredMultiPattern of MultiPatterns.multi_patterns ColoredElements.colored_elements

(* Returns the colored multi-pattern having the color out_color as out color, the
 * multi-pattern mp as multi-pattern, and the list in_colors as input colors. *)
let make out_color mp in_colors =
    assert(MultiPatterns.arity mp = List.length in_colors);
    ColoredMultiPattern (ColoredElements.make out_color mp in_colors)

(* Returns the colored element forming the colored multi-pattern cmp. *)
let colored_element cmp =
    let ColoredMultiPattern ce = cmp in
    ce

(* Tests if the colored multi-pattern cmp is valid. *)
let is_valid cmp =
    let ce = colored_element cmp in
    MultiPatterns.is_valid (ColoredElements.element ce)
    && MultiPatterns.arity (ColoredElements.element ce)
    = List.length (ColoredElements.in_colors ce)

(* Returns the multi-pattern of the colored multi-pattern cmp. *)
let multi_pattern cmp =
    assert (is_valid cmp);
    cmp |> colored_element |> ColoredElements.element

(* Returns a string representation of the colored multi-pattern cmp. *)
let to_string cmp =
    assert (is_valid cmp);
    ColoredElements.to_string MultiPatterns.to_string (colored_element cmp)

(* Tests if all the atoms of the multi-pattern mp are on the degree monoid dm. *)
let is_on_degree_monoid dm cmp =
    assert (is_valid cmp);
    cmp |> multi_pattern |> MultiPatterns.is_on_degree_monoid dm

(* Returns the multiplicity of the colored multi-pattern cmp. *)
let multiplicity cmp =
    assert (is_valid cmp);
    cmp |> multi_pattern |> MultiPatterns.multiplicity


