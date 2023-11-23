(* Author: Samuele Giraudo
 * Creation: aug. 2019
 * Modifications: aug. 2019, dec. 2019, jan. 2020, apr. 2021, jul. 2022, nov. 2023
 *)

(* Returns an option on the ABC notation of the MIDI note note. Returns None if the MIDI
 * code of note is not between 0 and 127. *)
let midi_to_abc_note note =
    match note with
        |MIDI.Note 0 -> Some "C,,,,,"
        |MIDI.Note 1 -> Some "^C,,,,,"
        |MIDI.Note 2 -> Some "D,,,,,"
        |MIDI.Note 3 -> Some "^D,,,,,"
        |MIDI.Note 4 -> Some "E,,,,,"
        |MIDI.Note 5 -> Some "F,,,,,"
        |MIDI.Note 6 -> Some "^F,,,,,"
        |MIDI.Note 7 -> Some "G,,,,,"
        |MIDI.Note 8 -> Some "^G,,,,,"
        |MIDI.Note 9 -> Some "A,,,,,"
        |MIDI.Note 10 -> Some "^A,,,,,"
        |MIDI.Note 11 -> Some "B,,,,,"
        |MIDI.Note 12 -> Some "C,,,,"
        |MIDI.Note 13 -> Some "^C,,,,"
        |MIDI.Note 14 -> Some "D,,,,"
        |MIDI.Note 15 -> Some "^D,,,,"
        |MIDI.Note 16 -> Some "E,,,,"
        |MIDI.Note 17 -> Some "F,,,,"
        |MIDI.Note 18 -> Some "^F,,,,"
        |MIDI.Note 19 -> Some "G,,,,"
        |MIDI.Note 20 -> Some "^G,,,,"
        |MIDI.Note 21 -> Some "A,,,,"
        |MIDI.Note 22 -> Some "^A,,,,"
        |MIDI.Note 23 -> Some "B,,,,"
        |MIDI.Note 24 -> Some "C,,,"
        |MIDI.Note 25 -> Some "^C,,,"
        |MIDI.Note 26 -> Some "D,,,"
        |MIDI.Note 27 -> Some "^D,,,"
        |MIDI.Note 28 -> Some "E,,,"
        |MIDI.Note 29 -> Some "F,,,"
        |MIDI.Note 30 -> Some "^F,,,"
        |MIDI.Note 31 -> Some "G,,,"
        |MIDI.Note 32 -> Some "^G,,,"
        |MIDI.Note 33 -> Some "A,,,"
        |MIDI.Note 34 -> Some "^A,,,"
        |MIDI.Note 35 -> Some "B,,,"
        |MIDI.Note 36 -> Some "C,,"
        |MIDI.Note 37 -> Some "^C,,"
        |MIDI.Note 38 -> Some "D,,"
        |MIDI.Note 39 -> Some "^D,,"
        |MIDI.Note 40 -> Some "E,,"
        |MIDI.Note 41 -> Some "F,,"
        |MIDI.Note 42 -> Some "^F,,"
        |MIDI.Note 43 -> Some "G,,"
        |MIDI.Note 44 -> Some "^G,,"
        |MIDI.Note 45 -> Some "A,,"
        |MIDI.Note 46 -> Some "^A,,"
        |MIDI.Note 47 -> Some "B,,"
        |MIDI.Note 48 -> Some "C,"
        |MIDI.Note 49 -> Some "^C,"
        |MIDI.Note 50 -> Some "D,"
        |MIDI.Note 51 -> Some "^D,"
        |MIDI.Note 52 -> Some "E,"
        |MIDI.Note 53 -> Some "F,"
        |MIDI.Note 54 -> Some "^F,"
        |MIDI.Note 55 -> Some "G,"
        |MIDI.Note 56 -> Some "^G,"
        |MIDI.Note 57 -> Some "A,"
        |MIDI.Note 58 -> Some "^A,"
        |MIDI.Note 59 -> Some "B,"
        |MIDI.Note 60 -> Some "C"
        |MIDI.Note 61 -> Some "^C"
        |MIDI.Note 62 -> Some "D"
        |MIDI.Note 63 -> Some "^D"
        |MIDI.Note 64 -> Some "E"
        |MIDI.Note 65 -> Some "F"
        |MIDI.Note 66 -> Some "^F"
        |MIDI.Note 67 -> Some "G"
        |MIDI.Note 68 -> Some "^G"
        |MIDI.Note 69 -> Some "A"
        |MIDI.Note 70 -> Some "^A"
        |MIDI.Note 71 -> Some "B"
        |MIDI.Note 72 -> Some "c"
        |MIDI.Note 73 -> Some "^c"
        |MIDI.Note 74 -> Some "d"
        |MIDI.Note 75 -> Some "^d"
        |MIDI.Note 76 -> Some "e"
        |MIDI.Note 77 -> Some "f"
        |MIDI.Note 78 -> Some "^f"
        |MIDI.Note 79 -> Some "g"
        |MIDI.Note 80 -> Some "^g"
        |MIDI.Note 81 -> Some "a"
        |MIDI.Note 82 -> Some "^a"
        |MIDI.Note 83 -> Some "b"
        |MIDI.Note 84 -> Some "c'"
        |MIDI.Note 85 -> Some "^c'"
        |MIDI.Note 86 -> Some "d'"
        |MIDI.Note 87 -> Some "^d'"
        |MIDI.Note 88 -> Some "e'"
        |MIDI.Note 89 -> Some "f'"
        |MIDI.Note 90 -> Some "^f'"
        |MIDI.Note 91 -> Some "g'"
        |MIDI.Note 92 -> Some "^g'"
        |MIDI.Note 93 -> Some "a'"
        |MIDI.Note 94 -> Some "^a'"
        |MIDI.Note 95 -> Some "b'"
        |MIDI.Note 96 -> Some "c''"
        |MIDI.Note 97 -> Some "^c''"
        |MIDI.Note 98 -> Some "d''"
        |MIDI.Note 99 -> Some "^d''"
        |MIDI.Note 100 -> Some "e''"
        |MIDI.Note 101 -> Some "f''"
        |MIDI.Note 102 -> Some "^f''"
        |MIDI.Note 103 -> Some "g''"
        |MIDI.Note 104 -> Some "^g''"
        |MIDI.Note 105 -> Some "a''"
        |MIDI.Note 106 -> Some "^a''"
        |MIDI.Note 107 -> Some "b''"
        |MIDI.Note 108 -> Some "c'''"
        |MIDI.Note 109 -> Some "^c'''"
        |MIDI.Note 110 -> Some "d'''"
        |MIDI.Note 111 -> Some "^d'''"
        |MIDI.Note 112 -> Some "e'''"
        |MIDI.Note 113 -> Some "f'''"
        |MIDI.Note 114 -> Some "^f'''"
        |MIDI.Note 115 -> Some "g'''"
        |MIDI.Note 116 -> Some "^g'''"
        |MIDI.Note 117 -> Some "a'''"
        |MIDI.Note 118 -> Some "^a'''"
        |MIDI.Note 119 -> Some "b'''"
        |MIDI.Note 120 -> Some "c''''"
        |MIDI.Note 121 -> Some "^c''''"
        |MIDI.Note 122 -> Some "d''''"
        |MIDI.Note 123 -> Some "^d''''"
        |MIDI.Note 124 -> Some "e''''"
        |MIDI.Note 125 -> Some "f''''"
        |MIDI.Note 126 -> Some "^f''''"
        |MIDI.Note 127 -> Some "g''''"
        |_ -> None

(* Returns an option on a string representing the atom a under the context ct in the ABC
 * notation. Returns None if a note encoded by p is outside the MIDI note range. *)
let atom_to_abc_string ct a =
    assert (Contexts.is_valid ct);
     match a with
        |Atoms.Rest -> Some "z"
        |Atoms.Beat d -> midi_to_abc_note (Contexts.degree_to_midi_note ct d)

(* Returns an option on a string representing the pattern p under the context ct in the ABC
 * notation. Returns None if a note encoded by p is outside the MIDI note range. *)
let pattern_to_abc_string ct p =
    assert (Contexts.is_valid ct);
    p
    |> Patterns.atoms
    |> List.map (fun a -> Options.map (fun s -> s ^ " ") (atom_to_abc_string ct a))
    |> List.fold_left (Options.map_2 (^)) (Some "")

(* Returns an option on a string representing the multi-pattern mp under the context ct in
 * the ABC notation. Returns None if a note encoded by mp is outside the MIDI note range. *)
let multi_pattern_to_abc_string ct mp =
    assert (Contexts.is_valid ct);
    assert (MultiPatterns.is_valid mp);
    assert (Contexts.number_midi_programs ct >= (MultiPatterns.multiplicity mp));
    let p_strs = mp |> MultiPatterns.patterns |> List.map (pattern_to_abc_string ct) in
    if p_strs |> List.exists Option.is_none then
        None
    else
        let p_strs = p_strs |> List.map Option.get in
        let str =
            p_strs
            |> List.mapi
                (fun i str ->
                    Printf.sprintf
                        "%%\nV: %d clef=treble\nL: 1/4\n%%%%MIDI program %d\n%s\n"
                        (i + 1)
                        (MIDI.program_code (Contexts.midi_program ct i))
                        str)
            |> String.concat ""
            in
        Some str

(* Returns an option on a string in the ABC notation representing the multi-pattern mp under
 * the context ct. This string contains all the information to be a valid ABC program.
 * Returns None if a note encoded by mp is outside the MIDI note range. *)
let complete_abc_string ct mp =
    assert (Contexts.is_valid ct);
    assert (MultiPatterns.is_valid mp);
    assert (Contexts.number_midi_programs ct >= (MultiPatterns.multiplicity mp));
    let str_mp = multi_pattern_to_abc_string ct mp in
    if Option.is_none str_mp then
        None
    else
        let str =
            Printf.sprintf
                "X: 1\nT: Track\nC: Bud Music Box\nM: 4/4\nK: Am\nQ: 1/4=%d\n\
                %%%%MIDI nobarlines\n%%\n%s"
                (Contexts.tempo ct)
                (Option.get str_mp)
        in
        Some str

