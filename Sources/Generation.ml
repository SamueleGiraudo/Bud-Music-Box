(* Author: Samuele Giraudo
 * Creation: dec. 2019
 * Modifications: dec. 2019, jan. 2020, apr. 2020, apr. 2021, aug. 2022, nov. 2023
 *)

(* A set of parameters for the pattern generation from bud grammars. *)
type parameters = {
    nb_steps: int;
    shape: BudGrammars.generation_shapes
}

(* Returns the parameters with the specified information. *)
let make_parameters nb_steps shape =
    assert (nb_steps >= 0);
    {nb_steps = nb_steps; shape = shape}

(* Returns the number of steps of the parameters param. *)
let nb_steps param =
    param.nb_steps

(* Returns the generation shape of the parameters param. *)
let shape param =
    param.shape

(* Returns the element generated at random from the colored multi-patterns of the list
 * colored multi-patterns with the generation parameters param, initial color initial_color,
 * and degree monoid dm. The list colored_multi_patterns must be nonempty. *)
let from_colored_multi_patterns param initial_color dm colored_multi_patterns =
    assert (colored_multi_patterns <> []);
    let m =
        MultiPatterns.multiplicity
            (ColoredElements.element (List.hd colored_multi_patterns))
    in
    let budg =
        BudGrammars.make
            (MultiPatterns.operad dm m)
            colored_multi_patterns initial_color
    in
    let res = BudGrammars.random_generator budg param.nb_steps param.shape in
    ColoredElements.element res

