(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* A colored element is an element of an operad augmented with output an input colors. The
 * type parameter 'a is the type of the underlying non-colored element. *)
type 'a colored_elements = {
    out_color: Colors.colors ;
    element: 'a ;
    in_colors: Colors.colors list
}

(* Returns the colored element with the specified attributes. *)
let make out_color element in_colors =
    {out_color = out_color; element = element; in_colors = in_colors}

(* Tests if ce is a well-formed colored element. This is the case if and only if the number
 * of input colors is the same as the arity of the underlying element of ce. *)
let belongs operad ce =
    Operads.arity operad ce.element = List.length ce.in_colors

(* Returns the color of the output of the colored element ce. *)
let out_color ce =
    ce.out_color

(* Returns the underlying element of the colored element ce. *)
let element ce =
    ce.element

(* Returns the list of the colors of the inputs of the colored element ce. *)
let in_colors ce =
    ce.in_colors

(* Returns the color of the i-th input of the colored element ce. *)
let in_color ce i =
    assert (1 <= i && i <= List.length ce.in_colors);
    List.nth ce.in_colors (i - 1)

(* Returns a string representing the colored element ce, where element_to_string is a map
 * sending any underlying object to a string representing it. *)
let to_string element_to_string ce =
    Printf.sprintf "%s | %s | %s"
        (Colors.to_string ce.out_color)
        (element_to_string (element ce))
        (Strings.from_list Colors.to_string " " ce.in_colors)

