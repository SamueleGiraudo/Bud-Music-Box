(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020, apr. 2021, jul. 2022, aug. 2022, nov. 2023
 *)

(* Names for multi-patterns and colored multi-patterns. *)
type names = string

(* All the possible program instructions. *)
type instructions =
    |Show
    |Write of names
    |Play of names
    |SetScale of Scales.scales
    |SetRoot of MIDI.notes
    |SetTempo of int
    |SetSounds of MIDI.programs list
    |SetDegreeMonoid of DegreeMonoids.degree_monoids
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
type programs = Program of instructions list

(* Returns the list of the instructions forming the program p. *)
let instructions p =
    let Program instr = p in
    instr

