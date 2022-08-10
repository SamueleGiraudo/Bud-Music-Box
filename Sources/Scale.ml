(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, dec. 2019, jan. 2020, apr. 2020, oct. 2020,
 * apr. 2021, jul. 2022, aug. 2022
 *)

(* A degree is a (possibly negative) integer. *)
type degree = int

(* A scale is a list of integers. This represents the integer composition associated with
 * the scale. *)
type scale = int list

(* Tests if the list lst is a scale. *)
let is_valid lst =
    if lst = [] then
        false
    else
        lst |> List.for_all (fun x -> x >= 1)

(* The minor natural scale. *)
let minor_natural = [2; 1; 2; 2; 1; 2; 2]

(* Returns the string representing the scale scale. For instance, the minor pentatonic scale
 * is represented by "3 2 2 3 2". *)
let to_string scale =
    assert (is_valid scale);
    Tools.list_to_string string_of_int " " scale

(* Returns the number of steps by octave in the scale scale. *)
let nb_steps_by_octave scale =
    assert (is_valid scale);
    scale |> List.fold_left (+) 0

(* Returns the number of notes by octave in the scale scale. *)
let nb_notes_by_octave scale =
    assert (is_valid scale);
    List.length scale

(* Returns the interval in semitones between the degree deg and its next degree in the scale
 * scale. *)
let next_interval scale deg =
    assert (is_valid scale);
    let nb_no = nb_notes_by_octave scale in
    let deg' = deg mod nb_no in
    if deg' >= 0 then
        List.nth scale deg'
    else
        List.nth scale (deg' + nb_no)

(* Returns the interval in steps between the root and the degree deg in the scale scale. The
 * interval is negative if the degree is negative. *)
let rec interval_from_root scale deg =
    assert (is_valid scale);
    if deg = 0 then
        0
    else if deg >= 1 then
        let deg' = deg - 1 in
        (next_interval scale deg') + (interval_from_root scale deg')
    else
        - (interval_from_root (List.rev scale) (- deg))

