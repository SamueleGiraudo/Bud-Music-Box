(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019, dec. 2019, jan. 2020, jul. 2022,
 * nov. 2023
 *)

(* A context allow to play a pattern. It consists in a root note (encoded as in midi), in a
 * tempo (number of beats per second), and in a scale. *)
type contexts = {
    scale: Scales.scales;
    root: MIDI.notes;
    tempo: int;
    midi_programs: MIDI.programs list
}

(* Tests if the context ct is valid. *)
let is_valid ct =
    Scales.is_valid ct.scale && MIDI.is_valid_note ct.root && ct.tempo >= 1
    && (ct.midi_programs |> List.for_all MIDI.is_valid_program)

(* Returns the context with the specified attributes. *)
let make scale root tempo midi_programs =
    assert (Scales.is_valid scale);
    assert (MIDI.is_valid_note root);
    assert (1 <= tempo);
    {scale = scale; root = root; tempo = tempo; midi_programs = midi_programs}

(* Returns the scale of the context ct. *)
let scale ct =
    ct.scale

(* Returns the root note of the context ct. *)
let root ct =
    ct.root

(* Returns the tempo of the context ct. *)
let tempo ct =
    ct.tempo

(* Returns the number of MIDI programs of the context ct. *)
let number_midi_programs ct =
    List.length ct.midi_programs

(* Returns the MIDI program of index i of the context ct. *)
let midi_program ct i =
    assert (0 <= i && i < number_midi_programs ct);
    List.nth ct.midi_programs i

(* Returns the midi node corresponding with the degree deg in the context ct. *)
let degree_to_midi_note ct deg =
    let c_root = MIDI.note_code ct.root in
    let c = c_root + (Scales.interval_from_root ct.scale deg |> Degrees.value) in
    MIDI.Note c

