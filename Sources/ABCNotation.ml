(* Author: Samuele Giraudo
 * Creation: aug. 2019
 * Modifications: aug. 2019, dec. 2019, jan. 2020, apr. 2021, jul. 2022, nov. 2023
 *)

(* An exception for errors in conversions between MIDI notes and abc notation. *)
exception Error

(* Returns the abc notation of the MIDI note note. Raises Error if note is not between 0 and
 * 127. *)
let midi_to_abc_note note =
    match note with
        |MIDI.Note 0 -> "C,,,,,"   |MIDI.Note 1 -> "^C,,,,,"  |MIDI.Note 2 -> "D,,,,,"
        |MIDI.Note 3 -> "^D,,,,,"  |MIDI.Note 4 -> "E,,,,,"   |MIDI.Note 5 -> "F,,,,,"
        |MIDI.Note 6 -> "^F,,,,,"  |MIDI.Note 7 -> "G,,,,,"   |MIDI.Note 8 -> "^G,,,,,"
        |MIDI.Note 9 -> "A,,,,,"   |MIDI.Note 10 -> "^A,,,,," |MIDI.Note 11 -> "B,,,,,"
        |MIDI.Note 12 -> "C,,,,"   |MIDI.Note 13 -> "^C,,,,"  |MIDI.Note 14 -> "D,,,,"
        |MIDI.Note 15 -> "^D,,,,"  |MIDI.Note 16 -> "E,,,,"   |MIDI.Note 17 -> "F,,,,"
        |MIDI.Note 18 -> "^F,,,,"  |MIDI.Note 19 -> "G,,,,"   |MIDI.Note 20 -> "^G,,,,"
        |MIDI.Note 21 -> "A,,,,"   |MIDI.Note 22 -> "^A,,,,"  |MIDI.Note 23 -> "B,,,,"
        |MIDI.Note 24 -> "C,,,"    |MIDI.Note 25 -> "^C,,,"   |MIDI.Note 26 -> "D,,,"
        |MIDI.Note 27 -> "^D,,,"   |MIDI.Note 28 -> "E,,,"    |MIDI.Note 29 -> "F,,,"
        |MIDI.Note 30 -> "^F,,,"   |MIDI.Note 31 -> "G,,,"    |MIDI.Note 32 -> "^G,,,"
        |MIDI.Note 33 -> "A,,,"    |MIDI.Note 34 -> "^A,,,"   |MIDI.Note 35 -> "B,,,"
        |MIDI.Note 36 -> "C,,"     |MIDI.Note 37 -> "^C,,"    |MIDI.Note 38 -> "D,,"
        |MIDI.Note 39 -> "^D,,"    |MIDI.Note 40 -> "E,,"     |MIDI.Note 41 -> "F,,"
        |MIDI.Note 42 -> "^F,,"    |MIDI.Note 43 -> "G,,"     |MIDI.Note 44 -> "^G,,"
        |MIDI.Note 45 -> "A,,"     |MIDI.Note 46 -> "^A,,"    |MIDI.Note 47 -> "B,,"
        |MIDI.Note 48 -> "C,"      |MIDI.Note 49 -> "^C,"     |MIDI.Note 50 -> "D,"
        |MIDI.Note 51 -> "^D,"     |MIDI.Note 52 -> "E,"      |MIDI.Note 53 -> "F,"
        |MIDI.Note 54 -> "^F,"     |MIDI.Note 55 -> "G,"      |MIDI.Note 56 -> "^G,"
        |MIDI.Note 57 -> "A,"      |MIDI.Note 58 -> "^A,"     |MIDI.Note 59 -> "B,"
        |MIDI.Note 60 -> "C"       |MIDI.Note 61 -> "^C"      |MIDI.Note 62 -> "D"
        |MIDI.Note 63 -> "^D"      |MIDI.Note 64 -> "E"       |MIDI.Note 65 -> "F"
        |MIDI.Note 66 -> "^F"      |MIDI.Note 67 -> "G"       |MIDI.Note 68 -> "^G"
        |MIDI.Note 69 -> "A"       |MIDI.Note 70 -> "^A"      |MIDI.Note 71 -> "B"
        |MIDI.Note 72 -> "c"       |MIDI.Note 73 -> "^c"      |MIDI.Note 74 -> "d"
        |MIDI.Note 75 -> "^d"      |MIDI.Note 76 -> "e"       |MIDI.Note 77 -> "f"
        |MIDI.Note 78 -> "^f"      |MIDI.Note 79 -> "g"       |MIDI.Note 80 -> "^g"
        |MIDI.Note 81 -> "a"       |MIDI.Note 82 -> "^a"      |MIDI.Note 83 -> "b"
        |MIDI.Note 84 -> "c'"      |MIDI.Note 85 -> "^c'"     |MIDI.Note 86 -> "d'"
        |MIDI.Note 87 -> "^d'"     |MIDI.Note 88 -> "e'"      |MIDI.Note 89 -> "f'"
        |MIDI.Note 90 -> "^f'"     |MIDI.Note 91 -> "g'"      |MIDI.Note 92 -> "^g'"
        |MIDI.Note 93 -> "a'"      |MIDI.Note 94 -> "^a'"     |MIDI.Note 95 -> "b'"
        |MIDI.Note 96 -> "c''"     |MIDI.Note 97 -> "^c''"    |MIDI.Note 98 -> "d''"
        |MIDI.Note 99 -> "^d''"    |MIDI.Note 100 -> "e''"    |MIDI.Note 101 -> "f''"
        |MIDI.Note 102 -> "^f''"   |MIDI.Note 103 -> "g''"    |MIDI.Note 104 -> "^g''"
        |MIDI.Note 105 -> "a''"    |MIDI.Note 106 -> "^a''"   |MIDI.Note 107 -> "b''"
        |MIDI.Note 108 -> "c'''"   |MIDI.Note 109 -> "^c'''"  |MIDI.Note 110 -> "d'''"
        |MIDI.Note 111 -> "^d'''"  |MIDI.Note 112 -> "e'''"   |MIDI.Note 113 -> "f'''"
        |MIDI.Note 114 -> "^f'''"  |MIDI.Note 115 -> "g'''"   |MIDI.Note 116 -> "^g'''"
        |MIDI.Note 117 -> "a'''"   |MIDI.Note 118 -> "^a'''"  |MIDI.Note 119 -> "b'''"
        |MIDI.Note 120 -> "c''''"  |MIDI.Note 121 -> "^c''''" |MIDI.Note 122 -> "d''''"
        |MIDI.Note 123 -> "^d''''" |MIDI.Note 124 -> "e''''"  |MIDI.Note 125 -> "f''''"
        |MIDI.Note 126 -> "^f''''" |MIDI.Note 127 -> "g''''"
        |_ -> raise Error

(* Returns a string representing the atom a under the context ct in the abc notation.
 * Raises Error if a note encoded by p is outside the MIDI range. *)
let atom_to_abc_string ct a =
     match a with
        |Atoms.Rest -> "z"
        |Atoms.Beat d -> midi_to_abc_note (Contexts.degree_to_midi_note ct d)

(* Returns a string representing the pattern p under the context ct in the abc notation.
 * Raises Error if a note encoded by p is outside the MIDI range. *)
let pattern_to_abc_string ct p =
    p |> Patterns.atoms |> List.map (atom_to_abc_string ct) |> String.concat " "

(* Returns a string representing the multi-pattern mp under the context ct in the abc
 * notation. Raises Error if a note encoded by mp is outside the MIDI range. *)
let multi_pattern_to_abc_string ct mp =
    assert (Contexts.is_valid ct);
    assert (MultiPatterns.is_valid mp);
    assert (Contexts.number_midi_programs ct >= (MultiPatterns.multiplicity mp));
    let lst =
        mp
        |> MultiPatterns.patterns
        |> List.mapi
            (fun i p ->
                "%\n"
                ^ Printf.sprintf "V: %d clef=treble\n" (i + 1)
                ^ "L: 1/4\n"
                ^ Printf.sprintf "%%%%MIDI program %d\n"
                    (MIDI.program_code (Contexts.midi_program ct i))
                ^ pattern_to_abc_string ct p
                ^ "\n")
    in
    (String.concat "" lst)

(* Returns a string in the abc notation representing the multi-pattern mp under the context
 * ct. This string contains all the information to be a valid abc program. Raises Error if a
 * note encoded by mp is outside the MIDI range. *)
let complete_abc_string ct mp =
    assert (Contexts.is_valid ct);
    assert (MultiPatterns.is_valid mp);
    assert (Contexts.number_midi_programs ct >= (MultiPatterns.multiplicity mp));
      "X: 1\n"
    ^ "T: Track\n"
    ^ "C: Bud Music Box\n"
    ^ "M: 4/4\n"
    ^ "K: Am\n"
    ^ Printf.sprintf "Q: 1/4=%d\n" (Contexts.tempo ct)
    ^ "%%MIDI nobarlines\n"
    ^ "%\n"
    ^ multi_pattern_to_abc_string ct mp

