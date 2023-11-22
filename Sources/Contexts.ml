(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019, dec. 2019, jan. 2020, jul. 2022,
 * nov. 2023
 *)

(* A midi note is an integer between 0 and 127. The value 60 represents the middle C. *)
type midi_notes = int

(* A context allow to play a pattern. It consists in a root note (encoded as in midi), in a
 * tempo (number of beats per second), and in a scale. *)
type contexts = {
    scale: Scales.scales;
    root: midi_notes;
    tempo: int;
}

(* Returns the context with the specified attributes. *)
let create scale root tempo =
    assert (Scales.is_valid scale);
    assert (0 <= root && root < 128);
    assert (1 <= tempo);
    {scale = scale; root = root; tempo = tempo}

(* Returns a string representing the context context. *)
let to_string ct =
      Printf.sprintf "scale: %s\n" (Scales.to_string ct.scale)
    ^ Printf.sprintf "MIDI root note:% d\n" ct.root
    ^ Printf.sprintf "tempo: %d bpm" ct.tempo
    |> Strings.indent 4

(* Returns the scale of the context ct. *)
let scale ct =
    ct.scale

(* Returns the root note of the context ct. *)
let root ct =
    ct.root

(* Returns the tempo of the context ct. *)
let tempo ct =
    ct.tempo

(* Returns the context obtained by replacing the scale of the context ct by scale. *)
let set_scale ct scale =
    assert (Scales.is_valid scale);
    {ct with scale = scale}

(* Returns the context obtained by replacing the root note of the context ct by root. *)
let set_root ct root =
    assert (0 <= root && root < 128);
    {ct with root = root}

(* Returns the context obtained by replacing the tempo of the context ct by tempo. *)
let set_tempo ct tempo =
    assert (1 <= tempo);
    {ct with tempo = tempo}

(* Returns the midi node corresponding with the degree deg in the context ct. *)
let degree_to_midi_note ct deg =
    ct.root + (Scales.interval_from_root ct.scale deg |> Degrees.value)

