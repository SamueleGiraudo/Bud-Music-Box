(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020
 *)

type name = string

type instruction =
    |Help
    |Quit
    |Show
    |Write of name * name
    |Play of name
    |SetScale of Scale.scale
    |SetRoot of int
    |SetTempo of int
    |SetSounds of int list
    |MultiPattern of name * MultiPattern.multi_pattern
    |Transpose of name * name * int
    |Mirror of name * name
    |Concatenate of name * (name list)
    |Repeat of name * name * int
    |Transform of name * name * int * (int list)
    |PartialCompose of name * name * int * name
    |FullCompose of name * name * (name list)
    |BinarilyCompose of name * name * name
    |Colorize of name * name * BudGrammar.color * (BudGrammar.color list)
    |Generate of name * BudGrammar.generation_shape * int * BudGrammar.color * (name list)
    |Temporize of name * BudGrammar.generation_shape * int * name * int
    |Rhythmize of name * BudGrammar.generation_shape * int * name * name
    |Harmonize of name * BudGrammar.generation_shape * int * name * name
    |Arpeggiate of name * BudGrammar.generation_shape * int * name * name
    |Mobiusate of name * BudGrammar.generation_shape * int * name

type state = {
    context : Context.context;
    midi_sounds : int list;
    multi_patterns : (string * MultiPattern.multi_pattern) list;
    colored_multi_patterns : (string * MultiPattern.colored_multi_pattern) list;
}


