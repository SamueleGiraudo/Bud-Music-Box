(* Author: Samuele Giraudo
 * Creation: aug. 2019
 * Modifications: aug. 2019, sep. 2019, dec. 2019, jan. 2020
 *)

(* An environment contains all the data needed to represent an execution state. *)
type environment = {
    context : Context.context;
    midi_sounds : int list;
    multi_patterns : (string * MultiPattern.multi_pattern) list;
    colored_multi_patterns : (string * MultiPattern.colored_multi_pattern) list;
    exit : bool
}

(* Some exceptions to handle instructions containing errors. *)
exception SyntaxError
exception ValueError
exception ExecutionError

(* Returns a string representing the environment env. *)
let environment_to_string env =
    Printf.sprintf
        "Context:\n%s\nMIDI sounds:\n%s\nMulti-patterns:\n%s\nColored multi-patterns:\n%s"
        (Context.to_string env.context)
        ("    " ^ (Tools.list_to_string string_of_int " " env.midi_sounds))
        ("    " ^ (Tools.list_to_string
            (fun (name, mpat) ->
                Printf.sprintf "%s = %s" name (MultiPattern.to_string mpat))
            "\n    "
            env.multi_patterns))
        ("    " ^ (Tools.list_to_string
            (fun (name, cpat) ->
                Printf.sprintf "%s = %s" name
                    (BudGrammar.colored_element_to_string MultiPattern.to_string cpat))
            "\n    "
            env.colored_multi_patterns))

(* Returns the environment obtained by adding the multi-pattern mpat with the name name.
 * If there is already a multi-pattern with this name, it is overwritten. *)
let add_multi_pattern env name mpat =
    let new_lst = (name, mpat) :: (List.remove_assoc name env.multi_patterns) in
    {env with multi_patterns = new_lst}

(* Returns the environment obtained by adding the colored multi-pattern cpat with the name
 * name. If there is already a colored multi-pattern with this name, it is overwritten. *)
let add_colored_multi_pattern env name cpat =
    let new_lst = (name, cpat) :: (List.remove_assoc name env.colored_multi_patterns) in
    {env with colored_multi_patterns = new_lst}

(* Returns the default midi sound (Acoustic Grand Piano). *)
let default_midi_sound = 0

(* Returns the extension of the file containing commands for the generation. *)
let extension = "bmb"

(* The relative path of the directory containing the generated temporary results. *)
let path_results = "Results"

(* The prefix of all the generated temporary result files  *)
let prefix_result = "Phrase_"

let help_file_path = "Help.md"

(* Returns the default environment. *)
let default_environment =
    {context = Context.create Scale.minor_harmonic 57 192;
    midi_sounds = [];
    multi_patterns = [];
    colored_multi_patterns = [];
    exit = false}

let is_name str =
    String.get str 0 = '$'

(* Returns the multi-pattern of name name in the environment env. If there is no such
 * multi-pattern, the exception Not_found is raised. *)
let multi_pattern_with_name env name =
    List.assoc name env.multi_patterns

(* Returns the colored multi-pattern of name name in the environment env. If there is no
 * such colored multi-pattern, the exception Not_found is raised. *)
let colored_multi_pattern_with_name env name =
    List.assoc name env.colored_multi_patterns

(* Returns the help string, containing explanations for each command. *)
let help_string =
    let help_file = open_in help_file_path in
    Std.input_list help_file |> String.concat "\n"

(* Returns a string containing the current date. *)
let date_string () =
    let tmp = Unix.gettimeofday () in
    let t = Unix.localtime tmp in
    Printf.sprintf "%d-%d-%d_%d:%d:%d"
        (t.tm_year + 1900) t.tm_mon t.tm_mday t.tm_hour t.tm_min t.tm_sec

(* Create an ABC file, a postscript file, and a MIDI file of the multi-pattern mpat from the
 * environment env. All the generated files have as name file_name, augmented with their
 * adequate extension. Returns true if the creation is possible and false otherwise. *)
let create_files env mpat file_name =
    let file_name_abc = file_name ^ ".abc" in
    let file_name_ps = file_name ^ ".ps" in
    let file_name_mid = file_name ^ ".mid" in
    if Sys.file_exists file_name_abc || Sys.file_exists file_name_ps
            || Sys.file_exists file_name_mid then
        false
    else begin
        let m = MultiPattern.multiplicity mpat in
        let diff_m = m - List.length env.midi_sounds in
        let midi_sounds = if diff_m <= 0 then
            env.midi_sounds
        else
            List.append env.midi_sounds (List.init diff_m (fun _ -> default_midi_sound))
        in
        let str_abc = ABCNotation.complete_abc_string env.context midi_sounds mpat in
        let file_abc = open_out file_name_abc in
        Printf.fprintf file_abc "%s\n" str_abc;
        close_out file_abc;
        Sys.command ("abcm2ps " ^ file_name_abc ^ " -O " ^ file_name_ps);
        Sys.command ("abc2midi " ^ file_name_abc ^ " -o " ^ file_name_mid);
        true
    end

(* Play the phrase from the environment env. Returns true if the playing is possible and
 * false otherwise. *)
let play_phrase env mpat =
    let file_name = Printf.sprintf "%s/%s%f"
        path_results prefix_result (Unix.gettimeofday ()) in
    let err = create_files env mpat file_name in
    if not err then
        false
    else
        let file_name_mid = file_name ^ ".mid" in
        let err = Sys.command ("timidity " ^ file_name_mid) in
        not (Tools.int_to_bool err)

let command_comment words env =
    if List.hd words <> "#" then
        None
    else begin
        print_string "Comment.";
        print_newline ();
        Some env
    end

let command_quit words env =
    if List.hd words <> "quit" then
        None
    else begin
        print_string "Quit.\n";
        print_newline ();
        let env' = {env with exit = true} in
        Some env'
    end

let command_help words env =
    if List.hd words <> "help" then
        None
    else begin
        print_string "Help.\n";
        print_string help_string;
        print_newline ();
        Some env
    end

let command_show words env =
    if List.hd words <> "show" then
        None
    else begin
        print_string "Current environment:\n";
        print_string (environment_to_string env);
        print_newline ();
        Some env
    end

let command_set_scale words env =
    if List.hd words <> "set_scale" then
        None
    else
        try
            let scale = List.tl words |> String.concat " " |> Scale.from_string in
            if not ((Scale.nb_steps_by_octave scale) = 12) then
                raise ValueError;
            let env' = {env with context = Context.set_scale env.context scale} in
            Printf.printf "Scale set to %s." (Scale.to_string scale);
            print_newline ();
            Some env'
        with
            |Tools.BadStringFormat -> begin
                print_string "Error: input format. Integers expected.";
                print_newline ();
                Some env
            end
            |Tools.BadValue -> begin
                print_string "Error: value. A scale is expected.";
                print_newline ();
                Some env
            end
            |ValueError -> begin
                print_string "Error: value. A 12-scale is expected.";
                print_newline ();
                Some env
            end

let command_set_root words env =
    if List.hd words <> "set_root" then
        None
    else
        try
            let root = int_of_string (List.nth words 1) in
            if not ((0 <= root) && (root < 128)) then
                raise ValueError;
            let env' = {env with context = Context.set_root env.context root} in
            Printf.printf "Root note set to %d." root;
            print_newline ();
            Some env'
        with
            |Failure _ -> begin
                print_string "Error: input format. Integer expected.";
                print_newline ();
                Some env
            end
            |ValueError -> begin
                print_string "Error: value. A note between 0 and 127 is expected.";
                print_newline ();
                Some env
            end

let command_set_tempo words env =
    if List.hd words <> "set_tempo" then
        None
    else
        try
            let tempo = int_of_string (List.nth words 1) in
            if not (tempo >= 1) then
                raise ValueError;
            let env' = {env with context = Context.set_tempo env.context tempo} in
            Printf.printf "Tempo set to %d." tempo;
            print_newline ();
            Some env'
        with
            |Failure _ -> begin
                print_string "Error: input format. Integer expected.";
                print_newline ();
                Some env
            end
            |ValueError -> begin
                print_string "Error: value. A tempo equal as 1 or greater is expected.";
                print_newline ();
                Some env
            end

let command_set_sounds words env =
    if List.hd words <> "set_sounds" then
        None
    else
        try
            let midi_sounds = List.tl words |> List.map int_of_string in
            if midi_sounds |> List.exists (fun s -> s < 0 || s > 127) then
                raise ValueError;
            let env' = {env with midi_sounds = midi_sounds} in
            Printf.printf "MIDI sounds set";
            print_newline ();
            Some env'
        with
            |Failure _ -> begin
                print_string "Error: input format. Integers expected.";
                print_newline ();
                Some env
            end
            |ValueError -> begin
                print_string "Error: input format. A MIDI sound list is a list of integers \
                    between 0 and 127";
                print_newline ();
                Some env
            end

let command_name_multi_pattern words env =
    if List.length words < 3 || not (is_name (List.nth words 0))
            || List.nth words 1 <> ":=" || List.nth words 2 <> "multi_pattern" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let str_mpat = Tools.factor_list words 3 ((List.length words) - 3)
                |> String.concat " " in
            let mpat = MultiPattern.from_string str_mpat in
            let env' = add_multi_pattern env name mpat in
            print_string "Multi-pattern added.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError | Tools.BadStringFormat | Tools.BadValue -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end

let command_name_colored_multi_pattern words env =
    if List.length words < 3 || not (is_name (List.nth words 0))
            || List.nth words 1 <> ":=" || List.nth words 2 <> "colored_multi_pattern" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let str_cpat = Tools.factor_list words 3 ((List.length words) - 3)
                |> String.concat " " in
            let cpat = BudGrammar.colored_element_from_string 
                MultiPattern.from_string str_cpat in
            let env' = add_colored_multi_pattern env name cpat in
            print_string "Colored multi-pattern added.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError | Tools.BadStringFormat | Tools.BadValue -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end

let command_partial_compose words env =
    if List.length words < 6 || not (is_name (List.nth words 0))
            || not (is_name (List.nth words 3)) || not (is_name (List.nth words 5))
            || List.nth words 1 <> ":=" || List.nth words 2 <> "partial_compose" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let name_1 = Tools.remove_first_char (List.nth words 3) in
            let mpat_1 = multi_pattern_with_name env name_1 in
            let pos = int_of_string (List.nth words 4) in
            if not (1 <= pos && pos <= (MultiPattern.arity mpat_1)) then
                raise ValueError;
            let name_2 = Tools.remove_first_char (List.nth words 5) in
            let mpat_2 = multi_pattern_with_name env name_2 in
            if MultiPattern.multiplicity mpat_1 <> MultiPattern.multiplicity mpat_2 then
                raise ValueError;
            let res = MultiPattern.partial_composition mpat_1 pos mpat_2 in
            let env' = add_multi_pattern env name res in
            print_string "Partial composition computed.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

let command_full_compose words env =
    if List.length words < 5 || not (is_name (List.nth words 0))
            || not (is_name (List.nth words 3)) || not (is_name (List.nth words 4))
            || List.nth words 1 <> ":=" || List.nth words 2 <> "full_compose" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let name_1 = Tools.remove_first_char (List.nth words 3) in
            let mpat_1 = multi_pattern_with_name env name_1 in
            let name_lst = Tools.factor_list words 4 ((List.length words) - 4) |> List.map
                Tools.remove_first_char in
            let mpat_lst = name_lst |> List.map (multi_pattern_with_name env) in
            if (List.length mpat_lst) <> (MultiPattern.arity mpat_1) then
                raise ValueError;
            if not (mpat_lst |> List.for_all
                (fun mpat ->
                    MultiPattern.multiplicity mpat = MultiPattern.multiplicity mpat_1)) then
                raise ValueError;
            let res = MultiPattern.full_composition mpat_1 mpat_lst in
            let env' = add_multi_pattern env name res in
            print_string "Full composition computed.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

let command_transform words env =
    if List.length words < 6 || not (is_name (List.nth words 0))
            || not (is_name (List.nth words ((List.length words) - 1)))
            || List.nth words 1 <> ":=" || List.nth words 2 <> "transform" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let name_1 = Tools.remove_first_char
                (List.nth words ((List.length words) - 1)) in
            let mpat_1 = multi_pattern_with_name env name_1 in
            let dilatation = int_of_string (List.nth words 3) in
            if dilatation < 0 then
                raise ValueError;
            let mul_lst = Tools.factor_list words 4 ((List.length words) - 5) |> List.map
                int_of_string in
            if List.length mul_lst <> MultiPattern.multiplicity mpat_1 then
                raise ValueError;
            let mpat = MultiPattern.transform dilatation mul_lst mpat_1 in
            let env' = add_multi_pattern env name mpat in
            print_string "Transformation computed.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

let command_mirror words env =
    if List.length words <> 4 || not (is_name (List.nth words 0))
            || not (is_name (List.nth words 3)) || List.nth words 1 <> ":="
            || List.nth words 2 <> "mirror" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let name_1 = Tools.remove_first_char (List.nth words 3) in
            let mpat_1 = multi_pattern_with_name env name_1 in
            let mpat = MultiPattern.mirror mpat_1 in
            let env' = add_multi_pattern env name mpat in
            print_string "Mirror computed.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

let command_generate words env =
    if List.length words < 6 || not (is_name (List.nth words 0))
            || List.nth words 1 <> ":=" || List.nth words 2 <> "generate" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let shape = BudGrammar.generation_shape_from_string (List.nth words 3) in
            let size = int_of_string (List.nth words 4) in
            let initial_color = List.nth words 5 in
            let colored_multi_patterns_names = Tools.factor_list
                words 6 ((List.length words) - 6) in
            let colored_multi_patterns = colored_multi_patterns_names |> List.map
                (fun name ->
                    let name' = Tools.remove_first_char name in
                    colored_multi_pattern_with_name env name') in
            if colored_multi_patterns = [] then
                raise ValueError;
            let m = MultiPattern.multiplicity
                (BudGrammar.get_element (List.hd colored_multi_patterns)) in
            if not (colored_multi_patterns |> List.for_all
                (fun cm ->
                    (MultiPattern.multiplicity (BudGrammar.get_element cm)) = m)) then
                raise ValueError;
            let mpat = Generation.from_colored_multi_patterns
                (Generation.create_parameters initial_color size shape)
                initial_color
                colored_multi_patterns in
            let env' = add_multi_pattern env name mpat in
            print_string "Multi-pattern generated.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError | Tools.BadStringFormat -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

let command_temporize words env =
    if List.length words < 7 || not (is_name (List.nth words 0))
            || not (is_name (List.nth words 5)) || List.nth words 1 <> ":="
            || List.nth words 2 <> "temporize" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let shape = BudGrammar.generation_shape_from_string (List.nth words 3) in
            let size = int_of_string (List.nth words 4) in
            if size < 0 then
                raise ValueError;
            let name_1 = Tools.remove_first_char (List.nth words 5) in
            let mpat_1 = multi_pattern_with_name env name_1 in
            if MultiPattern.multiplicity mpat_1 <> 1 then
                raise ValueError;
            let max_delay = int_of_string (List.nth words 6) in
            if max_delay < 0 then
                raise ValueError;
            let param = Generation.create_parameters
                Generation.default_initial_color size shape in
            let mpat = Generation.temporization
                param (MultiPattern.pattern mpat_1 1) max_delay in
            let env' = add_multi_pattern env name mpat in
            print_string "Temporization computed.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError | Tools.BadStringFormat -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

let command_rhythmize words env =
    if List.length words < 7 || not (is_name (List.nth words 0))
            || not (is_name (List.nth words 5)) || not (is_name (List.nth words 6))
            || List.nth words 1 <> ":=" || List.nth words 2 <> "rhythmize" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let shape = BudGrammar.generation_shape_from_string (List.nth words 3) in
            let size = int_of_string (List.nth words 4) in
            if size < 0 then
                raise ValueError;
            let name_1 = Tools.remove_first_char (List.nth words 5) in
            let mpat_1 = multi_pattern_with_name env name_1 in
            if MultiPattern.multiplicity mpat_1 <> 1 then
                raise ValueError;
            let name_2 = Tools.remove_first_char (List.nth words 6) in
            let mpat_2 = multi_pattern_with_name env name_2 in
            if MultiPattern.multiplicity mpat_2 <> 1 then
                raise ValueError;
            if MultiPattern.pattern mpat_1 1 |> Pattern.extract_degrees |> List.exists
                    (fun d -> d <> 0) then
                raise ValueError;
            let param = Generation.create_parameters
                Generation.default_initial_color size shape in
            let mpat = Generation.rhythmization
                param (MultiPattern.pattern mpat_1 1) (MultiPattern.pattern mpat_2 1) in
            let env' = add_multi_pattern env name mpat in
            print_string "Rhythmization computed.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError | Tools.BadStringFormat -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

let command_harmonize words env =
    if List.length words < 7 || not (is_name (List.nth words 0))
            || not (is_name (List.nth words 5)) || not (is_name (List.nth words 6))
            || List.nth words 1 <> ":=" || List.nth words 2 <> "harmonize" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let shape = BudGrammar.generation_shape_from_string (List.nth words 3) in
            let size = int_of_string (List.nth words 4) in
            if size < 0 then
                raise ValueError;
            let name_1 = Tools.remove_first_char (List.nth words 5) in
            let mpat_1 = multi_pattern_with_name env name_1 in
            if MultiPattern.multiplicity mpat_1 <> 1 then
                raise ValueError;
            let name_2 = Tools.remove_first_char (List.nth words 6) in
            let mpat_2 = multi_pattern_with_name env name_2 in
            if MultiPattern.multiplicity mpat_2 <> 1 then
                raise ValueError;
            if MultiPattern.length mpat_2 <> MultiPattern.arity mpat_2 then
                raise ValueError;
            let param = Generation.create_parameters
                Generation.default_initial_color size shape in
            let mpat = Generation.harmonization
                param (MultiPattern.pattern mpat_1 1) (MultiPattern.pattern mpat_2 1) in
            let env' = add_multi_pattern env name mpat in
            print_string "Harmonization computed.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError | Tools.BadStringFormat -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

let command_arpeggiate words env =
    if List.length words < 7 || not (is_name (List.nth words 0))
            || not (is_name (List.nth words 5)) || not (is_name (List.nth words 6))
            || List.nth words 1 <> ":=" || List.nth words 2 <> "arpeggiate" then
        None
    else
        try
            let name = Tools.remove_first_char (List.hd words) in
            let shape = BudGrammar.generation_shape_from_string (List.nth words 3) in
            let size = int_of_string (List.nth words 4) in
            if size < 0 then
                raise ValueError;
            let name_1 = Tools.remove_first_char (List.nth words 5) in
            let mpat_1 = multi_pattern_with_name env name_1 in
            if MultiPattern.multiplicity mpat_1 <> 1 then
                raise ValueError;
            let name_2 = Tools.remove_first_char (List.nth words 6) in
            let mpat_2 = multi_pattern_with_name env name_2 in
            if MultiPattern.multiplicity mpat_2 <> 1 then
                raise ValueError;
            if MultiPattern.length mpat_2 <> MultiPattern.arity mpat_2 then
                raise ValueError;
            let param = Generation.create_parameters
                Generation.default_initial_color size shape in
            let mpat = Generation.arpeggiation
                param (MultiPattern.pattern mpat_1 1) (MultiPattern.pattern mpat_2 1) in
            let env' = add_multi_pattern env name mpat in
            print_string "Arpeggiation computed.";
            print_newline ();
            Some env'
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError | Tools.BadStringFormat -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

let command_write words env =
    if List.hd words <> "write" || List.length words < 3
            || not (is_name (List.nth words 2)) then
        None
    else
        try
            let file_name = List.nth words 1 in
            let mpat_name = Tools.remove_first_char (List.nth words 2) in
            let mpat = multi_pattern_with_name env mpat_name in
            let ok = create_files env mpat file_name in
            if not ok then
                raise ExecutionError;
            print_string "The files has been generated.";
            print_newline ();
            Some env
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |ExecutionError -> begin
                print_string "Error: execution.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

let command_play words env =
    if List.hd words <> "play" || List.length words < 2
            || not (is_name (List.nth words 1)) then
        None
    else
        try
            let mpat_name = Tools.remove_first_char (List.nth words 1) in
            let mpat = multi_pattern_with_name env mpat_name in
            let ok = play_phrase env mpat in
            if not ok then
                raise ExecutionError;
            print_string "Phrase played.";
            print_newline ();
            Some env
        with
            |Invalid_argument _ | Failure _-> begin
                print_string "Error: bad formed instruction.";
                print_newline ();
                Some env
            end
            |ValueError -> begin
                print_string "Error: value.";
                print_newline ();
                Some env
            end
            |ExecutionError -> begin
                print_string "Error: execution.";
                print_newline ();
                Some env
            end
            |Not_found -> begin
                print_string "Error: name not bounded.";
                print_newline ();
                Some env
            end

(* Returns the next version of the environment env, altered by the command cmd. As side
 * effect, the action of the command is performed. *)
let execute_command cmd env =
        let words = Str.split (Str.regexp "[ \t\n]+") cmd in
        if words = [] then begin
            print_string "Empty instruction.";
            print_newline ();
            env
        end
        else let env_opt = command_comment words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_quit words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_help words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_show words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_set_scale words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_set_root words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_set_tempo words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_set_sounds words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_name_multi_pattern words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_name_colored_multi_pattern words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_partial_compose words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_full_compose words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_transform words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_mirror words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_generate words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_temporize words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_rhythmize words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_harmonize words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_arpeggiate words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_write words env in
        if Option.is_some env_opt then Option.get env_opt
        else let env_opt = command_play words env in
        if Option.is_some env_opt then Option.get env_opt
        else begin
            print_string "Error: unknown command.";
            print_newline ();
            env
        end

(* Launch the main interaction loop. *)
let interaction_loop () =
    let rec loop env =
        print_string "> ";
        let cmd = read_line () in
        let env' = execute_command cmd env in
        if env'.exit then
            exit 0
        else
            loop env'
    in
    loop default_environment

(* Interpret the file at path path containing some commands. Returns true if the file exists
 * and has the right extension and false otherwise. *)
let interpret_file path =
    if not (Sys.file_exists path) then begin
        Printf.printf "Error: the file %s does not exist.\n" path;
        false
    end
    else
        let len = String.length path in
        if len >= 4 && String.sub path (len - 4) 4 = "." ^ extension then begin
            let commands = Std.input_list (open_in path)
                |> List.filter (fun str -> str <> "") in
            commands |> List.fold_left
                (fun res cmd -> execute_command cmd res) default_environment;
            true
        end
        else begin
            Printf.printf "Error: the file must have %s as extension.\n" extension;
            false
        end


(* The test function of the module. *)
let test () =
    print_string "Test Interpreter\n";
    true

