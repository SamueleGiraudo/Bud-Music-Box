(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, may 2019, aug. 2019, dec. 2019
 *)

let name = "Bud Music Box"
let version = "0.01"
let author = "Samuele Giraudo"
let email = "samuele.giraudo@u-pem.fr"

let information =
    Printf.sprintf "%s\nCopyright (C) 2019 %s\nWritten by %s [%s]\nVersion: %s\n"
        name author author email version

let has_argument arg =
    Array.mem arg Sys.argv

let next_argument arg =
    let tmp = Tools.interval 0 ((Array.length Sys.argv) - 2) |> List.find_opt
        (fun i -> Sys.argv.(i) = arg) in
    match tmp with
        |None -> None
        |Some i -> Some Sys.argv.(i + 1)

;;

if has_argument "-r" then
    Random.init 0
else
    Random.self_init ();

if has_argument "-v" then begin
    print_string information
end;

if has_argument "-h" then begin
    print_string "Help:\n";
    print_string Interpreter.help_string
end;

if has_argument "-i" then begin
    print_string "Interpreter\n";
    Interpreter.interaction_loop ()
end;

if has_argument "-f" then begin
    let path = next_argument "-f" in
    if Option.is_none path then begin
        print_string "Error: a path must follow the -f argument.\n";
        exit 1
    end
    else begin
        let path = Option.get path in
        Printf.printf "Interpretation of %s...\n" path;
        let _ = Interpreter.interpret_file path in ()
    end
end;

exit 0;

(******************************************************************************************)
(******************************************************************************************)
(******************************************************************************************)

(* Some tests. *)

if false then begin
print_string "Tests\n";
Printf.printf "Tools: %s\n" (string_of_bool (Tools.test ()));
Printf.printf "Operad: %s\n" (string_of_bool (Operad.test ()));
Printf.printf "BudGrammar: %s\n" (string_of_bool (BudGrammar.test ()));
Printf.printf "Atom: %s\n" (string_of_bool (Atom.test ()));
Printf.printf "Scale: %s\n" (string_of_bool (Scale.test ()));
Printf.printf "Pattern: %s\n" (string_of_bool (Pattern.test ()));
Printf.printf "MultiPattern: %s\n"
    (string_of_bool (MultiPattern.test ()));
Printf.printf "Context: %s\n" (string_of_bool (Context.test ()));
Printf.printf "Interpreter %s\n" (string_of_bool (Interpreter.test ()));
end;




(*
exit 1;

(* Some shortcuts. *)
let b beat = Atom.Beat beat in
let r = Atom.Rest in

(* Creation of the context. *)
let context = Context.create 57 75 Scale.scale_harmonic_minor [1; 33] in

(* Some multi-patterns. *)
let pat_1_1 = [b 0 ; b 1 ; r ; b 2] in
let pat_1_2 = [b (-7) ; r ; b (-7) ; b 0] in
let mpat_1 = [pat_1_1 ; pat_1_2] in
let cpat_1 = BudGrammar.create_colored_element 'a' mpat_1
    ['c' ; 'c' ; 'a']
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);

let pat_2_1 = [b 1 ; b 2 ; b 1 ; b 2 ; b 0] in
let pat_2_2 = [b (-4) ; b 0 ; b (-4) ; b 0 ; b 0] in
let mpat_2 = [pat_2_1 ; pat_2_2] in
let cpat_2 = BudGrammar.create_colored_element 'a' mpat_2
    ['c' ; 'a' ; 'c' ; 'a' ; 'a'] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_2);

let pat_3_1 = [b 0 ; r] in
let pat_3_2 = [b 0 ; r] in
let mpat_3 = [pat_3_1 ; pat_3_2] in
let cpat_3 = BudGrammar.create_colored_element 2 mpat_3 [1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_3);

let pat_4_1 = [b 0 ; r] in
let pat_4_2 = [b 5 ; r] in
let mpat_4 = [pat_4_1 ; pat_4_2] in
let cpat_4 = BudGrammar.create_colored_element 3 mpat_3 [1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_4);

let pat_5_1 = [b 0 ; b 1 ; b 2 ; b 1] in
let mpat_5 = [pat_5_1] in
let cpat_5 = BudGrammar.create_colored_element 1 mpat_5 [1 ; 1 ; 1 ; 1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_5);

let pat_6_1 = [r] in
let mpat_6 = [pat_6_1] in
let cpat_6 = BudGrammar.create_colored_element 1 mpat_6 [] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_6);

let pat_7_1 = [] in
let mpat_7 = [pat_7_1] in
let cpat_7 = BudGrammar.create_colored_element 1 mpat_7 [] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_7);

(* Generators. *)
let gens = [cpat_1 ; cpat_2 ; cpat_3 ; cpat_4] in
(*let gens = [cpat_5 ; cpat_6 ; cpat_7] in*)

(* Multiplicity of the multi-patterns. *)
let k = (List.length mpat_1) in
(*let k = 1 in*)

(* Bud generating system. *)
let colors = [1 ; 2 ; 3] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens [1] [1]
in

(* Generation. *)
let generated = BudGrammar.synchronous_random_generator budg 6 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);

(* Printing the abc code. *)
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;

(* Creation of abc and files. *)
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";

(* Example of Rhythm.
 * A simple rhythm composed with itself. *)
if false then begin
let context = Context.create 57 128 Scale.scale_harmonic_minor [1; 33] in
let pat_1 = [b 0 ; b 0 ; r ; b 0 ; b 0 ; r ; b 0 ; b 0 ; r] in
let mpat_1 = [pat_1] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1
    ((Tools.interval 1 (Pattern.arity pat_1)) |> List.map (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);
let gens = [cpat_1] in
let k = (List.length mpat_1) in
let colors = [1] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens [1] [1]
in
let generated = BudGrammar.hook_random_generator budg 2 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;

(* Example of a pattern on a scale.
 * An ascending and descending sequence of degrees of the harmonic minor
 * scale composed with itself. *)
if false then begin
let context = Context.create 57 128 Scale.scale_harmonic_minor [1; 33] in
let pat_1 = [b 0 ; b 1 ; b 2 ; b 3 ; b 4 ; b 5 ; b 6 ; b 7 ;
    b 6 ; b 5 ; b 4 ; b 3 ; b 2 ; b 1 ; b 0] in
let mpat_1 = [pat_1] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1
    ((Tools.interval 1 (Pattern.arity pat_1)) |> List.map (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);
let gens = [cpat_1] in
let k = (List.length mpat_1) in
let colors = [1] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens [1] [1]
in
let generated = BudGrammar.hook_random_generator budg 16 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;

(* Example of two patterns on a scale.
 * The first pattern is an ascending and descending sequence of degrees,
 * and the second is a triad. *)
if false then begin
let context = Context.create 57 128 Scale.scale_harmonic_minor
    [1; 33] in
let pat_1 = [b 0 ; b 1 ; b (-1) ; b 3 ; b 0] in
let mpat_1 = [pat_1] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1
    ((Tools.interval 1 (Pattern.arity pat_1)) |> List.map (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);
let pat_2 = [b 0 ; b 2 ; b 4 ; b 2] in
let mpat_2 = [pat_2] in
let cpat_2 = BudGrammar.create_colored_element 1 mpat_2
    ((Tools.interval 1 (Pattern.arity pat_2)) |> List.map (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_2);
let gens = [cpat_1 ; cpat_2] in
let k = (List.length mpat_1) in
let colors = [1] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens [1] [1]
in
let generated = BudGrammar.hook_random_generator budg 16 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;

(* Example of three short patterns in the pentatonic minor scale. *)
if false then begin
let context = Context.create 57 88 Scale.scale_pentatonic_minor
    [1; 33] in
let pat_1 = [b 0 ; b 1 ; b 2] in
let mpat_1 = [pat_1] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1
    ((Tools.interval 1 (Pattern.arity pat_1)) |> List.map (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);
let pat_2 = [b 0 ; b (-1) ; b 0] in
let mpat_2 = [pat_2] in
let cpat_2 = BudGrammar.create_colored_element 1 mpat_2
    ((Tools.interval 1 (Pattern.arity pat_2)) |> List.map (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_2);
let pat_3 = [b 1 ; b 1] in
let mpat_3 = [pat_3] in
let cpat_3 = BudGrammar.create_colored_element 1 mpat_3
    ((Tools.interval 1 (Pattern.arity pat_3)) |> List.map (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_3);
let gens = [cpat_1 ; cpat_2 ; cpat_3] in
let k = (List.length mpat_1) in
let colors = [1] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens [1] [1]
in
let generated = BudGrammar.synchronous_random_generator budg 4 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;

(* Example of patterns with rhythm. *)
if false then begin
let context = Context.create 57 128 Scale.scale_diatonic_major
    [1; 33] in
let pat_1 = [b 0 ; r ; r ; r ; b 2 ; r ; b 1] in
let mpat_1 = [pat_1] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1
    ((Tools.interval 1 (Pattern.arity pat_1)) |> List.map
        (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);
let pat_2 = [b 0 ; b 0] in
let mpat_2 = [pat_2] in
let cpat_2 = BudGrammar.create_colored_element 1 mpat_2
    ((Tools.interval 1 (Pattern.arity pat_2)) |> List.map
        (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_2);
let gens = [cpat_1 ; cpat_2] in
let k = (List.length mpat_1) in
let colors = [1] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens
    [1] [1]
in
let generated = BudGrammar.synchronous_random_generator budg 5 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;

(* Example of one multi-pattern. *)
if false then begin
let context = Context.create 57 128 Scale.scale_harmonic_minor
    [1; 33] in
let pat_1 = [b 0; r;   b 2; r; b 4] in
let pat_2 = [r;   b 0; b 0; r; b 2] in
let mpat_1 = [pat_1; pat_2] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1
    ((Tools.interval 1 (Pattern.arity pat_1)) |> List.map
        (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);
let gens = [cpat_1] in
let k = (List.length mpat_1) in
let colors = [1] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens
    [1] [1]
in
let generated = BudGrammar.synchronous_random_generator budg 4 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;

(* Example of two multi-patterns. *)
if false then begin
let context = Context.create 57 96 Scale.scale_insen
    [1; 33] in
let pat_1_1 = [b 0;    b 0; b 1; r;   b 0; r] in
let pat_1_2 = [b (-1); r;   b 0; b 0; r;   b 2] in
let mpat_1 = [pat_1_1; pat_1_2] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1
    ((Tools.interval 1 (Pattern.arity pat_1_1)) |> List.map
        (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);

let pat_2_1 = [b 2; b 1; r; b 0] in
let pat_2_2 = [b (-1); b (-1); b (-1) ; r] in
let mpat_2 = [pat_2_1; pat_2_2] in
let cpat_2 = BudGrammar.create_colored_element 1 mpat_2
    ((Tools.interval 1 (Pattern.arity pat_2_1)) |> List.map
        (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_2);

let gens = [cpat_1; cpat_2] in
let k = (List.length mpat_1) in
let colors = [1] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens
    [1] [1]
in
let generated = BudGrammar.synchronous_random_generator budg 4 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;

(* Example of multi-patterns with colors *)
if false then begin
let context = Context.create 57 96 Scale.scale_diatonic_minor
    [1; 33] in
let pat_1_1 = [b 0;    r;      b 2; b 1; b 2; b 1] in
let pat_1_2 = [b (-7); b (-7); r;   b 0; b 0; b 0] in
let mpat_1 = [pat_1_1; pat_1_2] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1
    [2; 2; 1; 1; 1]
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);

let pat_2_1 = [b 0] in
let pat_2_2 = [b 0] in
let mpat_2 = [pat_2_1; pat_2_2] in
let cpat_2 = BudGrammar.create_colored_element 2 mpat_2
    [2]
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_2);

let gens = [cpat_1; cpat_2] in
let k = (List.length mpat_1) in
let colors = [1; 2] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens
    [1] [1]
in
let generated = BudGrammar.synchronous_random_generator budg 5 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;

(* Example of a more elaborated multi-patterns with colors. *)
if false then begin
let context = Context.create 57 96 Scale.scale_harmonic_minor
    [27; 33] in

(* First significant pattern. *)
let pat_1_1 = [b 0;    b 2;    r;   r;   b 3 ; b 1] in
let pat_1_2 = [b (-7); b (-3); b 0; b 1; r;    r] in
let mpat_1 = [pat_1_1; pat_1_2] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1 [2; 2; 1; 1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);

(* Second significant pattern. *)
let pat_2_1 = [b 0;    b 1; b 0] in
let pat_2_2 = [b (-7); b 0; b 0] in
let mpat_2 = [pat_2_1; pat_2_2] in
let cpat_2 = BudGrammar.create_colored_element 1 mpat_2 [2; 1; 1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_2);

(* Preserves notes colored by 2. *)
let pat_3_1 = [b 0] in
let pat_3_2 = [b 0] in
let mpat_3 = [pat_3_1; pat_3_2] in
let cpat_3 = BudGrammar.create_colored_element 2 mpat_3 [2] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_3);

(* Note doubling. *)
let pat_4_1 = [b 0; b 0] in
let pat_4_2 = [b 0; b 0] in
let mpat_4 = [pat_4_1; pat_4_2] in
let cpat_4 = BudGrammar.create_colored_element 1 mpat_4 [1; 1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_4);

(* Add temporization. *)
let pat_5_1 = [b 0; r] in
let pat_5_2 = [b 0; r] in
let mpat_5 = [pat_5_1; pat_5_2] in
let cpat_5 = BudGrammar.create_colored_element 1 mpat_5 [1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_5);

let gens = [cpat_1; cpat_2; cpat_3; cpat_4; cpat_5] in
let k = (List.length mpat_1) in
let colors = [1; 2] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens [1] [1]
in
let generated = BudGrammar.synchronous_random_generator budg 8 in
(*
let generated = BudGrammar.hook_random_generator budg 16 in
*)
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;

(* Example of a more elaborated multi-patterns with colors.
 * Other version. *)
if false then begin
let context = Context.create 57 76 Scale.scale_pentatonic_minor
    [27; 33] in

(* First significant pattern. *)
let pat_1_1 = [b 0;    r;      b (-1); r; b 2] in
let pat_1_2 = [b (-5); b (-5); b 0; r; r] in
let mpat_1 = [pat_1_1; pat_1_2] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1 [2; 2; 1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);

(* Second significant pattern. *)
let pat_2_1 = [b 1;    r ; b 0;    b 0] in
let pat_2_2 = [b (-4); b (-5); r ; b 0] in
let mpat_2 = [pat_2_1; pat_2_2] in
let cpat_2 = BudGrammar.create_colored_element 1 mpat_2 [2; 2; 1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_2);

(* Preserves notes colored by 2. *)
let pat_3_1 = [b 0] in
let pat_3_2 = [b 0] in
let mpat_3 = [pat_3_1; pat_3_2] in
let cpat_3 = BudGrammar.create_colored_element 2 mpat_3 [2] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_3);

(* Note doubling. *)
let pat_4_1 = [b 0; b 0] in
let pat_4_2 = [b 0; b 0] in
let mpat_4 = [pat_4_1; pat_4_2] in
let cpat_4 = BudGrammar.create_colored_element 1 mpat_4 [1; 1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_4);

(* Add temporization. *)
let pat_5_1 = [b 0; r] in
let pat_5_2 = [b 0; r] in
let mpat_5 = [pat_5_1; pat_5_2] in
let cpat_5 = BudGrammar.create_colored_element 1 mpat_5 [1] in
Printf.printf "%s\n" (MultiPattern.to_string mpat_5);

let gens = [cpat_1; cpat_2; cpat_3; cpat_4; cpat_5] in
let k = (List.length mpat_1) in
let colors = [1; 2] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens [1] [1]
in
(*
let generated = BudGrammar.synchronous_random_generator budg 10 in
*)
(*
let generated = BudGrammar.hook_random_generator budg 16 in
*)
let generated = BudGrammar.stratum_random_generator budg 16 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;

(* Simple example. *)
if true then begin
let context = Context.create 57 64 Scale.scale_insen
    [21; 15] in
let pat_1_1 = [b 0 ; b 1 ; r; r;  b 2] in
let pat_1_2 = [b (-2); r; r; b 0; b 1] in
let mpat_1 = [pat_1_1; pat_1_2] in
let cpat_1 = BudGrammar.create_colored_element 1 mpat_1
    ((Tools.interval 1 (Pattern.arity pat_1_1)) |> List.map (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_1);

let pat_2_1 = [b 0 ; r; b 2 ; b 4; b 2] in
let pat_2_2 = [r ; b 0; b 2 ; b (-1); b 2] in
let mpat_2 = [pat_2_1; pat_2_2] in
let cpat_2 = BudGrammar.create_colored_element 1 mpat_2
    ((Tools.interval 1 (Pattern.arity pat_2_1)) |> List.map (fun _ -> 1))
in
Printf.printf "%s\n" (MultiPattern.to_string mpat_2);

let gens = [cpat_1; cpat_2] in
let k = (List.length mpat_1) in
let colors = [1] in
let budg = BudGrammar.create (MultiPattern.operad k) colors gens [1] [1]
in
let generated = BudGrammar.hook_random_generator budg 32 in
let element = BudGrammar.get_element generated in
Printf.printf "%s\n" (MultiPattern.to_string element);
let str_abc = Context.complete_abc_string context element in
Printf.printf "%s\n" str_abc;
let file = open_out "File.abc" in
Printf.fprintf file "%s\n" str_abc;
close_out file;
Sys.command "abcm2ps File.abc";
()
end;


(* Creation of midi file and play. *)
Sys.command "abc2midi File.abc -o File.mid";
Sys.command "timidity File.mid";

*)

(* The end. *)
Printf.printf "End.\n"
