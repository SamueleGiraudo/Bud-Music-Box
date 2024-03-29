(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, aug. 2019, dec. 2019, jan. 2020, apr. 2020, oct. 2020,
 * apr. 2021, jul. 2022, nov. 2023
 *)

(* Returns the list of integers from a to b. *)
let interval a b =
    if a > b then [] else List.init (b - a + 1) (fun x -> x + a);;

(* Returns the factor of the list lst starting at position start and of length len. *)
let rec factor lst start len =
    match lst with
        |[] -> []
        |_ when len = 0 -> []
        |x :: lst' when start = 0 -> x :: (factor lst' 0 (len - 1))
        |_ :: lst' -> factor lst' (start - 1) len

(* Returns the list obtained by inserting the list lst_2 at position i in the list lst_1.
 * The numbering starts by 1. *)
let partial_composition lst_1 i lst_2 =
    assert ((1 <= i) && (i <= List.length lst_1));
    factor lst_1 0 (i - 1) @ lst_2 @ factor lst_1 i ((List.length lst_1) - i)

(* Returns an element of the list lst picked at random. *)
let pick_random lst =
    List.nth lst (Random.int (List.length lst))

