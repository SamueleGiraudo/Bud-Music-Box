(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019
 *)

(* A degree is a (possibly negative) integer. *)
type degree = int

(* A scale is a list of integers. This represent the integer composition
 * associated with the scale. *)
type scale = int list

let is_scale lst =
    if lst = [] then
        false
    else
        lst |> List.for_all (fun x -> x >= 1)

(* Some scales. *)
let minor_harmonic = [2; 1; 2; 2; 1; 3; 1]

let minor_pentatonic = [3; 2; 2; 3; 2]

let blues = [3; 2; 1; 1; 3; 2]

let major_natural = [2; 2; 1; 2; 2; 2; 1]

let minor_natural = [2 ; 1 ; 2 ; 2 ; 1 ; 2 ; 2]

let phrygian_dominant = [1; 3; 1; 2; 1; 2; 2]

let hirajoshi = [2; 1; 4; 1; 4]

let insen = [1; 4; 2; 3; 2]

let ryukyu = [4; 1; 2; 4; 1]

(* Returns the string representing the scale scale. For instance, the
 * minor pentatonic scale is represented by "3 2 2 3 2". *)
let to_string scale =
    assert (is_scale scale);
    Tools.list_to_string string_of_int " " scale

(* Returns the scale encoded by the string str. For instance,
 * "3 2 2 3 2" encodes the minor pentatonic scale. *)
let from_string str =
    Tools.list_from_string int_of_string ' ' str

(* Returns the number of steps by octave in the scale scale. *)
let nb_steps_by_octave scale =
    assert (is_scale scale);
    scale |> List.fold_left (+) 0

(* Returns the number of notes by octave in the scale scale. *)
let nb_notes_by_octave scale =
    assert (is_scale scale);
    List.length scale

(* Returns the interval in semitones between the degree deg and its next
 * degree in the scale scale. *)
let next_interval scale deg =
    assert (is_scale scale);
    List.nth scale (deg mod (List.length scale))

(* Returns the interval in steps between the root and the degree deg
 * in the scale scale. The interval is negative if the deg is
 * negative. *)
let rec interval_from_root scale deg =
    assert (is_scale scale);
    if deg = 0 then
        0
    else if deg >= 1 then
        let deg' = deg - 1 in
        (next_interval scale deg') + (interval_from_root scale deg')
    else
        - (interval_from_root (List.rev scale) (- deg))


(* The test function of the module. *)
let test () =
    print_string "Test Scale\n";
    true

