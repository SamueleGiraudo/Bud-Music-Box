(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020, apr. 2021, jul. 2022, aug. 2022, nov. 2023
 *)

(* Names for multi-patterns and colored multi-patterns. *)
type names = string

(* Names for paths. *)
type paths = string

(* The different possible degree monoids. *)
type degree_monoids =
    |Add
    |Cyclic of int
    |Max of int

(* All the possible program instructions. *)
type instructions =
    |Show
    |Write of names * paths
    |Play of names
    |SetScale of Scales.scales
    |SetRoot of Contexts.midi_notes
    |SetTempo of int
    |SetSounds of int list
    |SetDegreeMonoid of degree_monoids
    |MultiPattern of names * MultiPatterns.multi_patterns
    |Mirror of names * names
    |Inverse of names * names
    |Concatenate of names * (names list)
    |Repeat of names * names * int
    |Stack of names * (names list)
    |PartialCompose of names * names * int * names
    |FullCompose of names * names * (names list)
    |HomogeneousCompose of names * names * names
    |Colorize of names * names * BudGrammars.colors * (BudGrammars.colors list)
    |MonoColorize of names * names * BudGrammars.colors * BudGrammars.colors
    |Generate of
        names * BudGrammars.generation_shapes * int * BudGrammars.colors * (names list)

(* A program is a list of instructions. *)
type programs = instructions list

(* Returns a string representing the degree monoid dm. *)
let degree_monoid_to_string dm =
    match dm with
        |Add -> "Z"
        |Cyclic k -> Printf.sprintf "Z_%d" k
        |Max z -> Printf.sprintf "M_%d" z

