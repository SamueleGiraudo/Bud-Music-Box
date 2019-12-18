(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, aug. 2019
 *)

(* A midi note is an integer between 0 and 127. The value 60 represents
 * the middle C. *)
type midi_note = int

(* A context allow to play a pattern. It consists in a root note
 * (encoded as in midi), in a tempo (number of beats per second), and in
 * a scale. *)
type context = {
    scale : Scale.scale;
    root : midi_note;
    tempo : int;
}

(* Returns the context with the specified attributes. *)
let create scale root tempo =
    assert (Scale.is_scale scale);
    assert (0 <= root && root < 128);
    assert (1 <= tempo);
    {scale = scale; root = root; tempo = tempo}

let to_string context =
    Printf.sprintf ("midi root note: %d; tempo: %d bpm; scale: %s")
        context.root context.tempo (Scale.to_string context.scale)

let scale context =
    context.scale

let root context =
    context.root

let tempo context =
    context.tempo

let set_scale context scale =
    assert (Scale.is_scale scale);
    {context with scale = scale}

let set_root context root =
    assert (0 <= root && root < 128);
    {context with root = root}

let set_tempo context tempo =
    assert (1 <= tempo);
    {context with tempo = tempo}

(* Returns the midi node corresponding with the degree deg in the
 * context context. *)
let degree_to_midi_note context deg =
    context.root + (Scale.interval_from_root context.scale deg)


(* The test function of the module. *)
let test () =
    print_string "Test Context\n";
    true

