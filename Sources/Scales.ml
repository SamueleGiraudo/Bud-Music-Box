(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, dec. 2019, jan. 2020, apr. 2020, oct. 2020,
 * apr. 2021, jul. 2022, aug. 2022, nov. 2023
 *)

(* A scale is a list of integers. This represents the integer composition associated with
 * the scale, called profile of the scale. *)
type scales = Scale of int list

(* Returns the profile of the scale s. *)
let profile s =
    let Scale pr = s in
    pr

(* Tests if s is a well-formed scale. *)
let is_valid s =
    match profile s with
        |[] -> false
        |pr -> pr |> List.for_all (fun x -> x >= 1)

(* The minor natural scale. *)
let minor_natural = Scale [2; 1; 2; 2; 1; 2; 2]

(* Returns the string representing the scale s. For instance, the minor pentatonic scale is
 * represented by "3 2 2 3 2". *)
let to_string s =
    assert (is_valid s);
    s |> profile |> Strings.from_list string_of_int " "

(* Returns the number of steps by octave in the scale s. *)
let nb_steps_by_octave s =
    assert (is_valid s);
    s |> profile |> List.fold_left (+) 0

(* Returns the number of notes by octave in the scale s. *)
let nb_notes_by_octave s =
    assert (is_valid s);
    s |> profile |> List.length

(* Returns the i-th value of the scale s. *)
let value s i =
    assert (0 <= i && i < List.length (profile s));
    List.nth (profile s) i

(* Returns the mirror of the scale s. *)
let mirror s =
    Scale (s |> profile |> List.rev)

(* Returns the interval in semitones between the degree deg and its next degree in the scale
 * s. *)
let next_interval s deg =
    assert (is_valid s);
    let k = nb_notes_by_octave s in
    let deg' = deg |> Degrees.map (fun n -> n mod k) in
    if Degrees.value deg' >= 0 then
        deg' |> Degrees.map (value s)
    else
        deg' |> Degrees.map (fun n -> value s (n + k))

(* Returns the interval in steps between the root and the degree deg in the scale s. The
 * interval is negative if the degree is negative. *)
let rec interval_from_root s deg =
    assert (is_valid s);
    if Degrees.value deg = 0 then
        deg
    else if Degrees.value deg >= 1 then
        let deg' = deg |> Degrees.map pred in
        Degrees.operation (+) (next_interval s deg') (interval_from_root s deg')
    else
        let deg' = Degrees.opposite deg in
        (interval_from_root (mirror s) deg') |> Degrees.opposite

