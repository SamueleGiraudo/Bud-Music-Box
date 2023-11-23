(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019, sep. 2019, dec. 2019, jan. 2020,
 * apr. 2020, oct. 2020, aug. 2022, nov. 2023
 *)

(* A color is a name (string). *)
type colors = Color of string

(* A colored element is an element of an operad augmented with output an input colors. The
 * type parameter 'a is the type of the underlying non-colored element. *)
type 'a colored_elements = {
    out_color: colors ;
    element: 'a ;
    in_colors: colors list
}

(* Bud grammars. The type parameter 'a is the type of the elements of the underlying operad
 * of the bud grammar. *)
type 'a bud_grammars = {
    operad: 'a Operads.operads;
    generators: 'a colored_elements list;
    initial_color: colors
}

(* A type for specifying a random generation shape. *)
type generation_shapes =
    |Partial
    |Full
    |Homogeneous

(* Returns the name of the color c. *)
let color_name c =
    let Color name = c in
    name

(* Returns a string representation of the color c. *)
let color_to_string c =
    "%" ^ (color_name c)

(* Tests if ce is a well-formed colored element. This is the case if and only if the number
 * of input colors is the same as the arity of the underlying element of ce. *)
let is_colored_element operad ce =
    (Operads.arity operad ce.element) = (List.length ce.in_colors)

(* Returns the colored element with the specified attributes. *)
let make_colored_element out_color element in_colors =
    {out_color = out_color; element = element; in_colors = in_colors}

(* Returns the underlying element of the colored element ce. *)
let get_element ce =
    ce.element

(* Returns the color of the i-th input of the colored element ce. *)
let in_color ce i =
    assert ((1 <= i) && (i <= List.length ce.in_colors));
    List.nth ce.in_colors (i - 1)

(* Returns a string representing the colored element ce, where element_to_string is a map
 * sending any underlying object to a string representing it. *)
let colored_element_to_string element_to_string ce =
    Printf.sprintf "%s | %s | %s"
        (color_to_string ce.out_color)
        (element_to_string (get_element ce))
        (Strings.from_list color_to_string " " ce.in_colors)

(* Returns the bud grammar with the specified attributes. *)
let make operad generators initial_color =
    assert (generators |> List.for_all (is_colored_element operad));
    {operad = operad; generators = generators; initial_color = initial_color}

(* Returns the arity of the colored element ce in the bud grammar budg. *)
let arity budg ce =
    (Operads.arity budg.operad) ce.element

(* Returns the colored inity of color of the bud grammar budg. *)
let colored_unity budg color =
    {out_color = color; element = Operads.unity budg.operad; in_colors = [color]}

(* Returns the partial composition of y at position i in x in the colored operad of the bud
 * grammar budg. *)
let partial_composition budg x i y =
    assert ((1 <= i) && (i <= arity budg x));
    assert (y.out_color = (List.nth x.in_colors (i - 1)));
    let z' = Operads.partial_composition budg.operad x.element i y.element in
    let in_colors = Lists.partial_composition x.in_colors i y.in_colors in
    {out_color = x.out_color; element = z'; in_colors = in_colors}

(* Returns the full composition of each elements of the list lst in x in the colored operad
 * of the bud grammar budg. *)
let full_composition budg x lst =
    assert ((arity budg x) = (List.length lst));
    assert (List.for_all2 (=) x.in_colors (lst |> List.map (fun y -> y.out_color)));
    let indexed_elements = lst |> List.mapi (fun i y -> (i + 1, y)) |> List.rev in
    indexed_elements
    |> List.fold_left (fun res (i, y) -> partial_composition budg res i y) x

(* Returns the element obtained by composing all inputs of x having the same input color as
 * the output of y by y. *)
let colored_composition budg x y =
    let lst =
        List.init (arity budg x)
            (fun i ->
                let a = in_color x (i + 1) in
                if a = y.out_color then y else colored_unity budg a)
    in
    full_composition budg x lst

(* Returns the list of the generators of the bud grammar budg which have c as out color. *)
let generators_with_out_color budg c =
    budg.generators |> List.filter (fun g -> g.out_color = c)

(* Returns the colored element obtained by using the partial random generator algorithm on
 * the bug grammar budg after nb_iter iterations. *)
let partial_random_generator budg nb_iter =
    assert (nb_iter >= 0);
    Lists.interval 1 nb_iter
    |> List.fold_left
        (fun res _ ->
            let ar = arity budg res in
            if ar = 0 then
                res
            else
                let i = 1 + Random.int ar in
                let candidates = generators_with_out_color budg (in_color res i) in
                if candidates = [] then
                    res
                else
                    let y = Lists.pick_random candidates in
                    partial_composition budg res i y)
        (colored_unity budg budg.initial_color)

(* Returns the colored element obtained by using the full random generator algorithm on the
 * bug grammar budg after nb_iter iterations. *)
let full_random_generator budg nb_iter =
    assert (nb_iter >= 0);
    Lists.interval 1 nb_iter
    |> List.fold_left
        (fun res _ ->
            let candidates =  res.in_colors |> List.map
                (fun c -> generators_with_out_color budg c) in
            if candidates |> List.exists (fun lst -> lst = []) then
                res
            else
                let picked_gens = candidates |> List.map Lists.pick_random in
                full_composition budg res picked_gens)
        (colored_unity budg budg.initial_color)

(* Returns the colored element obtained by using the colored random generator algorithm on
 * the bug grammar budg after nb_iter iterations. This algorithm works by choosing at random
 * at each step a generator and performs to the right a colored composition with the element
 * generated at the previous step. *)
let homogeneous_random_generator budg nb_iter =
    assert (nb_iter >= 0);
    Lists.interval 1 nb_iter |> List.fold_left
        (fun res _ ->
            let y = Lists.pick_random budg.generators in
            colored_composition budg res y)
        (colored_unity budg budg.initial_color)

(* Returns an element generated at random by one of the three algorithms specified by shape.
 * The random generation uses the bud generating system budg and uses nb_iter iterations. *)
let random_generator budg nb_iter shape =
    assert (nb_iter >= 0);
    match shape with
        |Partial -> partial_random_generator budg nb_iter
        |Full -> full_random_generator budg nb_iter
        |Homogeneous -> homogeneous_random_generator budg nb_iter

