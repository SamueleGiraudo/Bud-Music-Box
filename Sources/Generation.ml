(* Author: Samuele Giraudo
 * Creation: dec. 2019
 * Modifications: dec. 2019, jan. 2020
 *)

(* A set of parameters for the pattern generation from bud grammars. *)
type parameters = {
    initial_color : BudGrammar.color;
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
    {initial_color = initial_color; nb_steps = nb_steps; shape = shape}

(* Returns the initial color of the parameters param. *)
let initial_color param =
    param.initial_color

(* Returns the number of steps of the parameters param. *)
let nb_steps param =
    param.nb_steps

(* Returns the generation shape of the parameters param. *)
let shape param =
    param.shape

(* Returns the parameters obtained by setting its number of steps at nb_steps from the
 * parameters param. *)
let set_nb_steps param nb_steps =
    assert (nb_steps >= 0);
    {param with nb_steps = nb_steps}

(* Returns the parameters obtained by setting its generation shape at shape from the
 * parameters param. *)
let set_shape param shape =
    {param with shape = shape}

(* Returns the element generated at random from the colored patterns of the list
 * colored_patterns with the generation parameters param. *)
let from_colored_patterns param colored_patterns =
    assert (colored_patterns <> []);
    let m = MultiPattern.multiplicity (BudGrammar.get_element (List.hd colored_patterns)) in
    let budg = BudGrammar.create
        (MultiPattern.operad m) colored_patterns param.initial_color in
    let res = BudGrammar.random_generator budg param.nb_steps param.shape in
    BudGrammar.get_element res

(* Returns the element generated at random from the 1-pattern pattern together with the 
 * nonnegative integer max_delay and the generation parameters param. *)
let temporization param pattern max_delay =
    assert (max_delay >= 0);
    assert (param.initial_color <> transition_color_1);
    assert (param.initial_color <> default_sink_color);
    let n = Pattern.arity pattern in
    let in_colors = List.init n (fun _ -> transition_color_1) in
    let mpat = MultiPattern.from_pattern pattern 1 in
    let cpat_1 = BudGrammar.create_colored_element param.initial_color mpat in_colors in
    let cpat_2 = BudGrammar.create_colored_element transition_color_1 mpat in_colors in
    let cpat_lst = Tools.interval 1 max_delay |> List.map
        (fun i ->
            let pat = Pattern.beat 0 (i + 1) in
            let mpat = MultiPattern.from_pattern pat 1 in
            BudGrammar.create_colored_element transition_color_1 mpat [default_sink_color])
    in
    from_colored_patterns param (cpat_1 :: cpat_2 :: cpat_lst)

(* Returns the element generated at random from the 1-pattern pattern together with the
 * degree list deg_lst and the generation parameters param. *)
let harmonization param pattern deg_lst =
    assert (deg_lst <> []);
    assert (param.initial_color <> transition_color_1);
    assert (param.initial_color <> default_sink_color);
    let m = List.length deg_lst in
    let n = Pattern.arity pattern in
    let mpat = MultiPattern.from_pattern pattern m in
    let in_colors = List.init n (fun _ -> transition_color_1) in
    let cpat_1 = BudGrammar.create_colored_element param.initial_color mpat in_colors in
    let cpat_2 = BudGrammar.create_colored_element transition_color_1 mpat in_colors in
    let mpat_3 = MultiPattern.chord deg_lst in
    let cpat_3 = BudGrammar.create_colored_element
        transition_color_1 mpat_3 [default_sink_color] in
    from_colored_patterns param [cpat_1; cpat_2; cpat_3]

(* Returns the element generated at random from the 1-pattern pattern together with the
 * degree list deg_lst and the generation parameters param. *)
let arpeggiation param pattern deg_lst =
    assert (deg_lst <> []);
    assert (param.initial_color <> transition_color_1);
    assert (param.initial_color <> default_sink_color);
    let m = List.length deg_lst in
    let n = Pattern.arity pattern in
    let mpat = MultiPattern.from_pattern pattern m in
    let in_colors = List.init n (fun _ -> transition_color_1) in
    let cpat_1 = BudGrammar.create_colored_element param.initial_color mpat in_colors in
    let cpat_2 = BudGrammar.create_colored_element transition_color_1 mpat in_colors in
    let mpat_3 = MultiPattern.arpeggio deg_lst in
    let cpat_3 = BudGrammar.create_colored_element
        transition_color_1 mpat_3 [default_sink_color] in
    from_colored_patterns param [cpat_1; cpat_2; cpat_3]

