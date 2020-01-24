(* Author: Samuele Giraudo
 * Creation: dec. 2019
 * Modifications: dec. 2019, jan. 2020
 *)

(* A set of parameters for the pattern generation from bud grammars. *)
type parameters = {
    nb_steps : int;
    shape : BudGrammar.generation_shape
}

(* The default initial color of the underlying bud grammar. *)
let default_initial_color = "a"

(* A transition color. *)
let transition_color_1 = "b"

(* A transition color. *)
let transition_color_2 = "c"

(* The default color for the sink, that is a color which does not appears as output color
 * of any pattern. *)
let default_sink_color = "z"

(* Returns the parameters with the specified information. *)
let create_parameters initial_color nb_steps shape =
    assert (nb_steps >= 0);
    {nb_steps = nb_steps; shape = shape}

(* Returns the number of steps of the parameters param. *)
let nb_steps param =
    param.nb_steps

(* Returns the generation shape of the parameters param. *)
let shape param =
    param.shape

(* Returns the element generated at random from the colored multi-patterns of the list
 * colored_multi-patterns with the generation parameters param. *)
let from_colored_multi_patterns param initial_color colored_multi_patterns =
    assert (colored_multi_patterns <> []);
    let m = MultiPattern.multiplicity (BudGrammar.get_element
        (List.hd colored_multi_patterns)) in
    let budg = BudGrammar.create
        (MultiPattern.operad m) colored_multi_patterns initial_color in
    let res = BudGrammar.random_generator budg param.nb_steps param.shape in
    BudGrammar.get_element res

(* Returns the element generated at random from the 1-pattern pattern together with the 
 * nonnegative integer max_delay and the generation parameters param. *)
let temporization param pattern max_delay =
    assert (max_delay >= 0);
    let n = Pattern.arity pattern in
    let in_colors = List.init n (fun _ -> transition_color_1) in
    let mpat = MultiPattern.from_pattern pattern 1 in
    let cpat_1 = BudGrammar.create_colored_element default_initial_color mpat in_colors in
    let cpat_2 = BudGrammar.create_colored_element transition_color_1 mpat in_colors in
    let cpat_lst = Tools.interval 1 max_delay |> List.map
        (fun i ->
            let pat = Pattern.beat 0 (i + 1) in
            let mpat = MultiPattern.from_pattern pat 1 in
            BudGrammar.create_colored_element transition_color_1 mpat [default_sink_color])
    in
    from_colored_multi_patterns param default_initial_color (cpat_1 :: cpat_2 :: cpat_lst)

(* Returns the element generated at random from the 1-pattern pattern together with the
 * 1-pattern rhythm consisting only in beats 0 and rests and the generation parameters
 * param. *)
let rhythmization param pattern rhythm =
    assert (Pattern.extract_degrees rhythm |> List.for_all (fun d -> d = 0));
    let n = Pattern.arity pattern in
    let mpat = MultiPattern.from_pattern pattern 1 in
    let in_colors = List.init n (fun _ -> transition_color_1) in
    let cpat_1 = BudGrammar.create_colored_element default_initial_color mpat in_colors in
    let cpat_2 = BudGrammar.create_colored_element transition_color_1 mpat in_colors in
    let mpat_3 = MultiPattern.from_pattern rhythm 1 in
    let in_colors' = List.init (Pattern.arity rhythm) (fun _ -> default_sink_color) in
    let cpat_3 = BudGrammar.create_colored_element transition_color_1 mpat_3 in_colors' in
    from_colored_multi_patterns param default_initial_color [cpat_1; cpat_2; cpat_3]

(* Returns the element generated at random from the 1-pattern pattern together with the
 * degree pattern deg_pattern and the generation parameters param. *)
let harmonization param pattern deg_pattern =
    assert (deg_pattern <> []);
    assert (deg_pattern |> List.for_all Atom.is_beat);
    let m = List.length deg_pattern in
    let n = Pattern.arity pattern in
    let mpat = MultiPattern.from_pattern pattern m in
    let in_colors = List.init n (fun _ -> transition_color_1) in
    let cpat_1 = BudGrammar.create_colored_element default_initial_color mpat in_colors in
    let cpat_2 = BudGrammar.create_colored_element transition_color_1 mpat in_colors in
    let mpat_3 = MultiPattern.chord deg_pattern in
    let cpat_3 = BudGrammar.create_colored_element
        transition_color_1 mpat_3 [default_sink_color] in
    from_colored_multi_patterns param default_initial_color [cpat_1; cpat_2; cpat_3]

(* Returns the element generated at random from the 1-pattern pattern together with the
 * degree list deg_lst and the generation parameters param. *)
let arpeggiation param pattern deg_pattern =
    assert (deg_pattern <> []);
    assert (deg_pattern |> List.for_all Atom.is_beat);
    let m = List.length deg_pattern in
    let n = Pattern.arity pattern in
    let mpat = MultiPattern.from_pattern pattern m in
    let in_colors = List.init n (fun _ -> transition_color_1) in
    let cpat_1 = BudGrammar.create_colored_element default_initial_color mpat in_colors in
    let cpat_2 = BudGrammar.create_colored_element transition_color_1 mpat in_colors in
    let mpat_3 = MultiPattern.arpeggio deg_pattern in
    let cpat_3 = BudGrammar.create_colored_element
        transition_color_1 mpat_3 [default_sink_color] in
    from_colored_multi_patterns param default_initial_color [cpat_1; cpat_2; cpat_3]

(* Returns the element generated at random from the 1-pattern pattern and the generation
 * parameters param. *)
let mobiusation param pattern =
    let pattern' = Pattern.mirror pattern in
    let mpat = [pattern; pattern'] in
    let in_colors = List.init (Pattern.arity pattern) (fun _ -> default_initial_color) in
    let cpat = BudGrammar.create_colored_element default_initial_color mpat in_colors in
    from_colored_multi_patterns param default_initial_color [cpat]

