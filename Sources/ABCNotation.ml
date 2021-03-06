(* Author: Samuele Giraudo
 * Creation: aug. 2019
 * Modifications: aug. 2019, dec. 2019, jan. 2020, apr. 2021
 *)

(* An exception for errors in conversions between MIDI notes and abc notation. *)
exception Error

(* Returns the abc notation of the MIDI note note. Raises Error if note is not between 0 and
 * 127. *)
let midi_to_abc_note note =
    match note with
        |0 -> "C,,,,,"   |1 -> "^C,,,,,"  |2 -> "D,,,,,"  |3 -> "^D,,,,,"  |4 -> "E,,,,,"
        |5 -> "F,,,,,"   |6 -> "^F,,,,,"  |7 -> "G,,,,,"  |8 -> "^G,,,,,"  |9 -> "A,,,,,"
        |10 -> "^A,,,,," |11 -> "B,,,,,"  |12 -> "C,,,,"  |13 -> "^C,,,,"  |14 -> "D,,,,"
        |15 -> "^D,,,,"  |16 -> "E,,,,"   |17 -> "F,,,,"  |18 -> "^F,,,,"  |19 -> "G,,,,"
        |20 -> "^G,,,,"  |21 -> "A,,,,"   |22 -> "^A,,,," |23 -> "B,,,,"   |24 -> "C,,,"
        |25 -> "^C,,,"   |26 -> "D,,,"    |27 -> "^D,,,"  |28 -> "E,,,"    |29 -> "F,,,"
        |30 -> "^F,,,"   |31 -> "G,,,"    |32 -> "^G,,,"  |33 -> "A,,,"    |34 -> "^A,,,"
        |35 -> "B,,,"    |36 -> "C,,"     |37 -> "^C,,"   |38 -> "D,,"     |39 -> "^D,,"
        |40 -> "E,,"     |41 -> "F,,"     |42 -> "^F,,"   |43 -> "G,,"     |44 -> "^G,,"
        |45 -> "A,,"     |46 -> "^A,,"    |47 -> "B,,"    |48 -> "C,"      |49 -> "^C,"
        |50 -> "D,"      |51 -> "^D,"     |52 -> "E,"     |53 -> "F,"      |54 -> "^F,"
        |55 -> "G,"      |56 -> "^G,"     |57 -> "A,"     |58 -> "^A,"     |59 -> "B,"
        |60 -> "C"       |61 -> "^C"      |62 -> "D"      |63 -> "^D"      |64 -> "E"
        |65 -> "F"       |66 -> "^F"      |67 -> "G"      |68 -> "^G"      |69 -> "A"
        |70 -> "^A"      |71 -> "B"       |72 -> "c"      |73 -> "^c"      |74 -> "d"
        |75 -> "^d"      |76 -> "e"       |77 -> "f"      |78 -> "^f"      |79 -> "g"
        |80 -> "^g"      |81 -> "a"       |82 -> "^a"     |83 -> "b"       |84 -> "c'"
        |85 -> "^c'"     |86 -> "d'"      |87 -> "^d'"    |88 -> "e'"      |89 -> "f'"
        |90 -> "^f'"     |91 -> "g'"      |92 -> "^g'"    |93 -> "a'"      |94 -> "^a'"
        |95 -> "b'"      |96 -> "c''"     |97 -> "^c''"   |98 -> "d''"     |99 -> "^d''"
        |100 -> "e''"    |101 -> "f''"    |102 -> "^f''"  |103 -> "g''"    |104 -> "^g''"
        |105 -> "a''"    |106 -> "^a''"   |107 -> "b''"   |108 -> "c'''"   |109 -> "^c'''"
        |110 -> "d'''"   |111 -> "^d'''"  |112 -> "e'''"  |113 -> "f'''"   |114 -> "^f'''"
        |115 -> "g'''"   |116 -> "^g'''"  |117 -> "a'''"  |118 -> "^a'''"  |119 -> "b'''"
        |120 -> "c''''"  |121 -> "^c''''" |122 -> "d''''" |123 -> "^d''''" |124 -> "e''''"
        |125 -> "f''''"  |126 -> "^f''''" |127 -> "g''''"
        |_ -> raise Error

(* Returns a string representing the pattern p under the context context in the abc
 * notation. Raises Error if a note encoded by p is outside the MIDI range. *)
let pattern_to_abc_string context p =
    let l = Tools.length_start p Atom.Rest in
    let first_rest_str =
        if l = 0 then
            ""
        else
            Printf.sprintf "z%d " l
    in
    let deg_dur = List.combine (Pattern.degrees p) (Pattern.durations p) in
    let str = deg_dur |> List.map
        (fun (deg, dur) ->
            let note = midi_to_abc_note (Context.degree_to_midi_note context deg) in
            (Printf.sprintf "%s%d" note dur)) in
    first_rest_str ^ (String.concat " " str)

(* Returns a string representing the multi-pattern mp under the context context in the abc
 * notation. The list midi_sounds contains the respective MIDI codes of the voices. Raises
 * Error if a note encoded by mp is outside the MIDI range. *)
let multi_pattern_to_abc_string context midi_sounds mp =
    assert (MultiPattern.is_valid mp);
    assert ((List.length midi_sounds) >= (MultiPattern.multiplicity mp));
    assert (midi_sounds |> List.for_all (fun s -> 0 <= s && s < 128));
    let lst = mp |> List.mapi
        (fun i p ->
            Printf.sprintf "V:voice%d\n%%%%MIDI program %d\n%s\n"
                (i + 1)
                (List.nth midi_sounds i)
                (pattern_to_abc_string context p)) in
    (String.concat "" lst) ^ "\n"

(* Returns a string in the abc notation representing the multi-pattern mp under the
 * context context and with the midi sounds specified by the integer list midi_sounds. This
 * string contains all the information to be a valid abc program. Raises Error if a note
 * encoded by mp is outside the MIDI range. *)
let complete_abc_string context midi_sounds mp =
    assert (MultiPattern.is_valid mp);
    assert ((List.length midi_sounds) >= (MultiPattern.multiplicity mp));
    assert (midi_sounds |> List.for_all (fun s -> 0 <= s && s < 128));
    let res = "" in
    let res = res ^ "X:1\n" in
    let res = res ^ "T:Music\n" in
    let res = res ^ "C:By Bud Music Box\n" in
    let res = res ^ "K:Am\n"in
    let res = res ^ "M:8/8\n" in
    let res = res ^ "L:1/8\n" in
    let res = res ^ (Printf.sprintf "Q:1/8=%d\n" (Context.tempo context)) in
    let res = res ^ "%%MIDI nobarlines\n" in
    let res = res ^ multi_pattern_to_abc_string context midi_sounds mp in
    res

