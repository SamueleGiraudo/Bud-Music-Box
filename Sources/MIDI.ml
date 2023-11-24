(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* A type for MIDI programs. *)
type programs = Program of int

(* A type for MIDI notes. *)
type notes = Note of int

(* Returns the code of the MIDI program p. *)
let program_code p =
    let Program v = p in
    v

(* Tests if the MIDI program p is a well-defined MIDI program. *)
let is_valid_program p =
    let c = program_code p in
    0 <= c && c <= 127

(* Returns the code of the MIDI note n. *)
let note_code n =
    let Note v = n in
    v

(* Tests if the MIDI note n is a well-defined MIDI note. *)
let is_valid_note n =
    let c = note_code n in
    0 <= c && c <= 127

(* Returns a string representation of the MIDI program p. *)
let program_to_string p =
    string_of_int (program_code p)

(* Returns a string representation of the MIDI note n. *)
let note_to_string n =
    string_of_int (note_code n)

