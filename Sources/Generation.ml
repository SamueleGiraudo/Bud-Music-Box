(* Author: Samuele Giraudo
 * Creation: dec. 2019
 * Modifications: dec. 2019, jan. 2020, apr. 2020, apr. 2021, aug. 2022
 *)

(* A set of parameters for the pattern generation from bud grammars. *)
type parameters = {
    nb_steps: int;
    shape: BudGrammar.generation_shape
}

(* Returns the parameters with the specified information. *)
let create_parameters nb_steps shape =
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
 * and degree monoid dm. *)
let from_colored_multi_patterns param initial_color dm colored_multi_patterns =
    assert (colored_multi_patterns <> []);
    let m = MultiPattern.multiplicity (BudGrammar.get_element
        (List.hd colored_multi_patterns)) in
    let budg = BudGrammar.create
        (MultiPattern.operad dm m) colored_multi_patterns initial_color in
    let res = BudGrammar.random_generator budg param.nb_steps param.shape in
    BudGrammar.get_element res

