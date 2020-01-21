(* Author: Samuele Giraudo
 * Creation: aug. 2019
 * Modifications: aug. 2019, sep. 2019, dec. 2019, jan. 2020
 *)

(* An environment contains all the data needed to represent an execution state. *)
type environment = {
    context : Context.context;
    midi_sounds : int list;
    multi_patterns : (string * MultiPattern.multi_pattern) list;
    colored_patterns : (string * MultiPattern.colored_pattern) list;
    exit : bool
}

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
            env.colored_patterns))

let add_multi_pattern env name mpat =
    let new_lst = (name, mpat) :: (List.remove_assoc name env.multi_patterns) in
    {env with multi_patterns = new_lst}

let add_colored_pattern env name cpat =
    let new_lst = (name, cpat) :: (List.remove_assoc name env.colored_patterns) in
    {env with colored_patterns = new_lst}

let default_midi_sound = 0

(* Returns the extension of the file containing commands for the generation. *)
let extension = "bmb"

(* The relative path of the directory containing the generated results. *)
let path_results = "Results"

(* The prefix of all the generated result files  *)
let prefix_result = "Phrase_"

let help_file_path = "Help.md"

(* Returns the default environment. *)
let default_environment =
    {context = Context.create Scale.minor_harmonic 57 192;
    midi_sounds = [];
    multi_patterns = [];
    colored_patterns = [];
    exit = false}

let multi_pattern_with_name env name =
    List.assoc name env.multi_patterns

let colored_multi_pattern_with_name env name =
    List.assoc name env.colored_patterns

(* Returns an option on the multiplicity of the pattern of the environment env. Returns
 * None if there is no pattern in env. *)
(*
let multiplicity env =
    match env.colored_patterns with
        |[] -> None
        |cpat :: _ ->
            let mpat = BudGrammar.get_element cpat in
            Some (MultiPattern.multiplicity mpat)
*)

(* Returns the environment obtained by setting at nb_steps the number of generation steps
 * of the environment env. *)
(*let set_nb_steps env nb_steps =
    assert (nb_steps >= 0);
    {env with parameters = Generation.set_nb_steps env.parameters nb_steps}
*)

(* Returns the environment obtained by setting at shape the generation shape of the
 * environment env. *)
(*let set_shape env shape =
    {env with parameters = Generation.set_shape env.parameters shape}
*)

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

(*
(* Create an abc file from the environment env. Returns true if the creation is possible and
 * false otherwise. *)
let create_abc_file env mpat file_name =
    let file_name_abc = file_name ^ ".abc" in
    if Sys.file_exists file_name_abc then
        false
    else begin
        let file_abc = open_out file_name_abc in
        let str_abc = ABCNotation.complete_abc_string env.context env.midi_sounds mpat in
        Printf.fprintf file_abc "%s\n" str_abc;
        close_out file_abc;
        true
    end

(* Create a ps file from the environment env. Returns true if the creation is possible and
 * false otherwise. *)
let create_score_file env file_name =
    let file_name_abc = file_name ^ ".abc" in
    if not (Sys.file_exists file_name_abc) then
        false
    else
        let file_name_ps = file_name ^ ".ps" in
        if Sys.file_exists file_name_ps then
            false
        else
             let err = Sys.command ("abcm2ps " ^ file_name_abc ^ " -O " ^ file_name_ps) in
             not (Tools.int_to_bool err)

(* Create a midi file from the environment env. Returns true if the creation is possible and
 * false otherwise. *)
let create_midi_file file_name =
    let file_name_abc = file_name ^ ".abc" in
    if not (Sys.file_exists file_name_abc) then
        false
    else
        let file_name_mid = file_name ^ ".mid" in
        if Sys.file_exists file_name_mid then
            false
        else
            let err = Sys.command ("abc2midi " ^ file_name_abc ^ " -o " ^ file_name_mid) in
             not (Tools.int_to_bool err)
*)

(* Play the phrase from the environment env. Returns true if the playing is possible and
 * false otherwise. *)
let play_phrase env mpat =
    let file_name_tmp = Printf.sprintf "tmp_%f" (Unix.gettimeofday ()) in
    let err = create_files env mpat file_name_tmp in
    if not err then
        false
    else
            let file_name_mid = file_name_tmp ^ ".mid" in
            let err = Sys.command ("timidity " ^ file_name_mid) in
            not (Tools.int_to_bool err)

(* Returns the next version of the environment env, altered by the command cmd. As side
 * effect, the action of the command is performed. *)
let execute_command cmd env =
        let words = Str.split (Str.regexp "[ \t\n]+") cmd in
        if words = [] then begin
            print_string "Empty instruction.";
            print_newline ();
            env
        end
        else if List.hd words = "#" then begin
            print_string "Comment.";
            print_newline ();
            env
        end
        else if List.hd words = "quit" then begin
            print_string "Quit.\n";
            let env' = {env with exit = true} in
            print_newline ();
            env'
        end
        else if List.hd words = "help" then begin
            print_string "Help.\n";
            print_string help_string;
            print_newline ();
            env
        end
        else if List.hd words = "show" then begin
            Printf.printf "Current environment:\n%s" (environment_to_string env);
            print_newline ();
            env
        end
        else if List.hd words = "set_scale" then begin
            try
                let scale = List.tl words |> List.map int_of_string in
                if Scale.is_scale scale && Scale.nb_steps_by_octave scale = 12
                    then begin
                    let env' =
                        {env with context = Context.set_scale env.context scale} in
                    Printf.printf "Scale set to %s." (Scale.to_string scale);
                    print_newline ();
                    env'
                end
                else begin
                    print_string "Error: scale. ";
                    print_string "Must have 12 steps and at least 1 note.";
                    print_newline ();
                    env
                end
            with
                |_ -> begin
                    print_string "Error: input format. Integers expected.";
                    print_newline ();
                    env
                end
        end
        else if List.hd words = "set_root" then begin
            try
                let str = List.nth words 1 in
                let root = int_of_string str in
                if (0 <= root) && (root < 128) then begin
                    let env' =
                        {env with context = Context.set_root env.context root} in
                    Printf.printf "Root note set to %d." root;
                    print_newline ();
                    env'
                end
                else begin
                    print_string "Error: the root note must be between 0 and 127.";
                    print_newline ();
                    env
                end
            with
                |_ -> begin
                    print_string "Error: input format. Integer expected.";
                    print_newline ();
                    env
                end
        end
        else if List.hd words = "set_tempo" then begin
            try
                let str = List.nth words 1 in
                let tempo = int_of_string str in
                if 1 <= tempo then begin
                    let env' =
                        {env with context = Context.set_tempo env.context tempo} in
                    Printf.printf "Tempo set to %d." tempo;
                    print_newline ();
                    env'
                end
                else begin
                    print_string "Error: the tempo must be 1 or more.";
                    print_newline ();
                    env
                end
            with
                |_ -> begin
                    print_string "Error: input format. Integer expected.";
                    print_newline ();
                    env
                end
        end
        else if List.hd words = "set_sounds" then begin
            try
                let midi_sounds = List.tl words |> List.map int_of_string in
                if midi_sounds |> List.for_all (fun s -> 0 <= s && s <= 127) then begin
                    let env' = {env with midi_sounds = midi_sounds} in
                    Printf.printf "MIDI sounds set";
                    print_newline ();
                    env'
                end
                else begin
                    print_string "Error: MIDI sounds. ";
                    print_string "Must be between 0 and 127.";
                    print_newline ();
                    env
                end
            with
                |_ -> begin
                    print_string "Error: input format. Integers expected.";
                    print_newline ();
                    env
                end
        end
        else if String.get (List.hd words) 0 = '$'&& (List.nth words 1) = ":="
                && (List.nth words 2) = "multi_pattern" then begin
            let name = Tools.remove_first_char (List.hd words) in
            let mpat = Tools.factor_list words 3 ((List.length words) - 3)
                |> String.concat " " in
            let mpat = MultiPattern.from_string mpat in
            let env' = add_multi_pattern env name mpat in
            print_string "Multi-pattern added.";
            print_newline ();
            env'
        end
        else if String.get (List.hd words) 0 = '$'&& (List.nth words 1) = ":="
                && (List.nth words 2) = "colored_multi_pattern" then begin
            let name = Tools.remove_first_char (List.hd words) in
            let cpat = Tools.factor_list words 3 ((List.length words) - 3)
                |> String.concat " " in
            let cpat = BudGrammar.colored_element_from_string
                MultiPattern.from_string cpat in
            let env' = add_colored_pattern env name cpat in
            print_string "Colored multi-pattern added.";
            print_newline ();
            env'
        end
        else if String.get (List.hd words) 0 = '$' && (List.nth words 1) = ":="
                && (List.nth words 2) = "generate" then begin
            let name = Tools.remove_first_char (List.hd words) in
            let shape = match List.nth words 3 with
                |"partial" -> BudGrammar.Partial
                |"full" -> BudGrammar.Full
                |"colored" -> BudGrammar.Colored
            in
            let size = int_of_string (List.nth words 4) in
            let initial_color = List.nth words 5 in
            let colored_patterns_names = Tools.factor_list
                words 6 ((List.length words) - 6) in
            let colored_patterns = colored_patterns_names |> List.map
                (fun name ->
                    let name' = Tools.remove_first_char name in
                    colored_multi_pattern_with_name env name') in
            let mpat = Generation.from_colored_patterns
                (Generation.create_parameters initial_color size shape)
                colored_patterns in
            let env' = add_multi_pattern env name mpat in
            env'
        end
        else if List.hd words = "write" then begin
            let file_name = List.nth words 1 in
            let mpat_name = Tools.remove_first_char (List.nth words 2) in
            let mpat = multi_pattern_with_name env mpat_name in
            let ok = create_files env mpat file_name in
            if ok then begin
                print_string "The files has been generated.";
                print_newline ()
            end
            else begin
                print_string "Error: the files have not been generated.";
                print_newline ()
            end;
            env
        end
        else if List.hd words = "play" then begin
            let mpat_name = Tools.remove_first_char (List.nth words 1) in
            let mpat = multi_pattern_with_name env mpat_name in
            let ok = play_phrase env mpat in
            if ok then
                print_string "Phrase played."
            else
                print_string "Error: the phrase cannot be played.";
            print_newline ();
            env
        end
        else begin
            print_string "Error: unknown command.";
            print_newline ();
            env
        end

        (*
        else if List.hd words = "transform" then begin
            if List.length words <= 3 then begin
                print_string "Error";
                print_newline ();
                env
            end
            else begin
                let dilatation = int_of_string (List.nth words 1) in
                let mul_lst = Tools.list_factor words 2 ((List.length word) - 3) in
                let name = Tools.remove_first_char
                    (List.nth words ((List.length words) - 1)) in
                let mpat = multi_pattern_with_name env 
            end
        end
        *)
        

(*
                |"morphism" -> begin
                    try
                        let str = List.nth cmd' 1 in
                        if Option.is_some env.result then begin
                            let g = Option.get env.result in
                            let k_lst = Tools.list_from_string int_of_string ' ' str in
                            if (MultiPattern.multiplicity g) <> List.length k_lst then begin
                                print_string
                                    "Error: the morphism has not the good multiplicity.";
                                print_newline ();
                                env
                            end
                            else begin
                                let g' = MultiPattern.exterior_product g k_lst in
                                let env' = {env with result = Some g'} in
                                print_string "The morphism has been applied on the phrase.";
                                print_newline ();
                                env'
                            end
                        end
                        else begin
                            print_string
                                "Error: morphism application impossible, there is no \
                                generated phrase.";
                            print_newline ();
                            env
                        end
                    with
                        |_ -> begin
                            print_string "Error: input format. Integers expected.";
                            print_newline ();
                            env
                        end
                end

                |"mirror" -> begin
                    if Option.is_some env.result then begin
                        let g = Option.get env.result in
                        let g' = MultiPattern.mirror g in
                        let env' = {env with result = Some g'} in
                        print_string "The phrase has been replaced by its mirror.";
                        print_newline ();
                        env'
                    end
                    else begin
                        print_string
                            "Error: mirror computation impossible, there is no generated \
                            phrase.";
                        print_newline ();
                        env
                    end
                end
*)

(*
                |"temporize" -> begin
                    try
                        let str = List.nth cmd' 1 in
                        let str = Tools.remove_blank_characters str in
                        let max_delay = int_of_string str in
                        if (List.length env.colored_patterns) <> 1
                                || (Option.get (multiplicity env)) <> 1 then begin
                            print_string "Error: temporization impossible, there must be \
                                one 1-pattern.";
                            print_newline ();
                            env
                        end
                        else if max_delay <= 0 then begin
                            print_string "Error: the maximal delay must be 1 or more.";
                            print_newline ();
                            env
                        end
                        else begin
                            let pat = MultiPattern.pattern
                                (BudGrammar.get_element (List.hd env.colored_patterns))
                                1
                            in
                            let g = Generation.temporization env.parameters pat max_delay in
                            let env' = {env with result = Some g} in
                            print_string "A temporization has been generated.";
                            print_newline ();
                            env'
                        end
                    with
                        |_ -> begin
                            print_string "Error: input format. Integer expected.";
                            print_newline ();
                            env
                        end
                end

                |"rhythmize" -> begin
                    try
                        let str = List.nth cmd' 1 in
                        let rhythm = Pattern.from_string str in
                        if (List.length env.colored_patterns) = 1
                                && (Option.get (multiplicity env)) = 1
                                && Pattern.extract_degrees rhythm |> List.for_all
                                    (fun d -> d = 0) then begin
                            let pat = MultiPattern.pattern
                                (BudGrammar.get_element (List.hd env.colored_patterns))
                                1
                            in
                            let g = Generation.rhythmization env.parameters pat rhythm in
                            let env' = {env with result = Some g} in
                            print_string "A rhytmization has been generated.";
                            print_newline ();
                            env'
                        end
                        else begin
                            print_string "Error: rhythmization impossible, there must be \
                                one 1-pattern, and a rhythm pattern as argument (only 0 \
                                and * ).";
                            print_newline ();
                            env
                        end
                    with
                        |_ -> begin
                            print_string "Error: input format. Rhythm pattern expected.";
                            print_newline ();
                            env
                        end
                end

                |"harmonize" -> begin
                    try
                        let str = List.nth cmd' 1 in
                        let deg_pattern = Pattern.from_string str in
                        if (List.length env.colored_patterns) = 1
                                && (Option.get (multiplicity env)) = 1
                                && deg_pattern |> List.for_all Atom.is_beat then begin
                            let pat = MultiPattern.pattern
                                (BudGrammar.get_element (List.hd env.colored_patterns))
                                1
                            in
                            let g = Generation.harmonization env.parameters pat deg_pattern
                            in
                            let env' = {env with result = Some g} in
                            print_string "A harmonization has been generated.";
                            print_newline ();
                            env'
                        end
                        else begin
                            print_string "Error: harmonization impossible, there must be \
                                one 1-pattern, and a degree pattern as argument.";
                            print_newline ();
                            env
                        end
                    with
                        |_ -> begin
                            print_string "Error: input format. Integers expected.";
                            print_newline ();
                            env
                        end
                end

                |"arpeggiate" -> begin
                    try
                        let str = List.nth cmd' 1 in
                        let deg_pattern = Pattern.from_string str in
                        if (List.length env.colored_patterns) = 1
                                && (Option.get (multiplicity env)) = 1
                                && deg_pattern |> List.for_all Atom.is_beat then begin
                            let pat = MultiPattern.pattern
                                (BudGrammar.get_element (List.hd env.colored_patterns))
                                1
                            in
                            let g = Generation.arpeggiation env.parameters pat deg_pattern
                            in
                            let env' = {env with result = Some g} in
                            print_string "An arpeggiation has been generated.";
                            print_newline ();
                            env'
                        end
                        else begin
                            print_string "Error: arpeggiation impossible, there must be \
                                one 1-pattern, and a degree pattern as argument.";
                            print_newline ();
                            env
                        end
                    with
                        |_ -> begin
                            print_string "Error: input format. Integers expected.";
                            print_newline ();
                            env
                        end
                end
*)

(*

                |"play" -> begin
                    if (Option.is_some env.file_name) then
                        let ok = play_phrase env in
                        if ok then
                            print_string "Phrase played."
                        else
                            print_string "Error: the phrase cannot be played.";
                    else
                        print_string
                            "The midi file has not been written, play is impossible.";
                    print_newline ();
                    env
                end

                |_ -> begin
                    print_string "Error: unknown command.";
                    print_newline ();
                    env
                end
*)


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

