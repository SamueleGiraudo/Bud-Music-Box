(* Author: Samuele Giraudo
 * Creation: aug. 2019
 * Modifications: aug. 2019, sep. 2019, dec. 2019
 *)

(* An environment contains all the data needed to represent an execution state. *)
type environment = {
    context : Context.context;
    generation_shape : BudGrammar.generation_shape;
    colored_patterns : MultiPattern.colored_pattern list;
    initial_color : BudGrammar.color;
    nb_steps : int;
    result : MultiPattern.multi_pattern option;
    file_name : string option;
    exit : bool
}

(* Returns the extension of the file containing commands for the generation. *)
let extension = "bmb"

(* The relative path of the directory containing the generated results. *)
let path_results = "Results"

(* The prefix of all the generated result files  *)
let prefix_result = "Phrase_"

(* The default initial color of the underlying bud grammar. *)
let default_initial_color = "a"

(* Returns the default environment. *)
let default_environment =
    {context = Context.create Scale.minor_harmonic 57 192;
    generation_shape = BudGrammar.Hook;
    colored_patterns = [];
    initial_color = default_initial_color;
    nb_steps = 64;
    result = None;
    file_name = None;
    exit = false}

(* Returns an option on the multiplicity of the pattern of the environment env. Returns
 * None if there is no pattern in env. *)
let multiplicity env =
    match env.colored_patterns with
        |[] -> None
        |cpat :: _ ->
            let mpat = BudGrammar.get_element cpat in
            Some (MultiPattern.multiplicity mpat)

(* Returns the help string, containing explanations for each command. *)
let help_string =
    "Available instructions:\n"
        ^ "+ help\n"
        ^ "    -> Print the help.\n"
        ^ "+ quit\n"
        ^ "    -> Quit the application.\n"
        ^ "+ show\n"
        ^ "    -> Print the current content of the generation parameters.\n"
        ^ "+ root = NOTE\n"
        ^ "    where NOTE is the integer code of a midi note.\n"
        ^ "    -> Set the root note, which is the one of degree 0.\n"
        ^ "+ tempo = VAL\n"
        ^ "    where VAL is a nonnegative integer.\n"
        ^ "    -> Set the tempo as VAL bpm.\n"
        ^ "+ scale = S1 S2 ... Sk\n"
        ^ "    where S1 S2 ... Sk is the integer composition of a 12-scale.\n"
        ^ "    -> Set the underlying set to the specified one.\n"
        ^ "+ shape = hook | synchronous | stratum\n"
        ^ "    -> Set the random generation algorithm.\n"
        ^ "+ steps = VAL\n"
        ^ "    where VAL is a nonnegative integer value.\n"
        ^ "    -> Set the number of generation step as VAL.\n"
        ^ "+ add : CMP \n"
        ^ "    where CMP is a colored mult-pattern.\n"
        ^ "    -> Add the specified pattern into the collection of patterns.\n"
        ^ "+ generate\n"
        ^ "    -> Generate a musical phrase from the current generation parameters.\n"
        ^ "+ write\n"
        ^ "    -> Create the ABC file, postscript file, and midi file from the generated \
            phrase.\n"
        ^ "+ play\n"
        ^ "    -> Play the current midi file.\n"

(* Returns a string containing the current date. *)
let date_string () =
    let tmp = Unix.gettimeofday () in
    let t = Unix.localtime tmp in
    Printf.sprintf "%d-%d-%d_%d:%d:%d"
        (t.tm_year + 1900) t.tm_mon t.tm_mday t.tm_hour t.tm_min t.tm_sec

(* Create an abc file from the environment env. Returns true if the creation is possible and
 * false otherwise. *)
let create_abc_file env =
    if Option.is_none env.file_name || Option.is_none env.result then
        false
    else begin
        let file_name_abc = (Option.get env.file_name) ^ ".abc" in
        let result = Option.get env.result in
        let file_abc = open_out file_name_abc in
        let str_abc = ABCNotation.complete_abc_string env.context result in
        Printf.fprintf file_abc "%s\n" str_abc;
        close_out file_abc;
        true
    end

(* Create a ps file from the environment env. Returns true if the creation is possible and
 * false otherwise. *)
let create_score_file env =
    if Option.is_none env.file_name then
        false
    else
        let file_name_abc = (Option.get env.file_name) ^ ".abc" in
        let file_name_ps = (Option.get env.file_name) ^ ".ps" in
        if not (Sys.file_exists file_name_abc) then
            false
        else
             let err = Sys.command ("abcm2ps " ^ file_name_abc ^ " -O " ^ file_name_ps) in
             if err = 0 then
                 true
             else
                false

(* Create a midi file from the environment env. Returns true if the creation is possible and
 * false otherwise. *)
let create_midi_file env =
     if Option.is_none env.file_name then
        false
    else
        let file_name_abc = (Option.get env.file_name) ^ ".abc" in
        let file_name_mid = (Option.get env.file_name) ^ ".mid" in
        if not (Sys.file_exists file_name_abc) then
            false
        else
            let err = Sys.command ("abc2midi " ^ file_name_abc ^ " -o " ^ file_name_mid) in
            if err = 0 then
                true
            else
                false

(* Play the phrase from the environment env. Returns true if the playing is possible and
 * false otherwise. *)
let play_phrase env =
    if Option.is_none env.file_name then
        false
    else
        let file_name_mid = (Option.get env.file_name) ^ ".mid" in
        if not (Sys.file_exists file_name_mid) then
            false
        else
            let err = Sys.command ("timidity " ^ file_name_mid) in
            if err = 0 then
                true
            else
                false

(* Returns the next version of the environment env, altered by the command cmd. As side
 * effect, the action of the command is performed. *)
let execute_command cmd env =
    let cmd' =  Str.split (Str.regexp "[=:]+") cmd in
    if cmd' = [] then begin
        print_string "Error: unknown command.\n";
        env
    end
    else
        let instr = Tools.remove_blank_characters (List.hd cmd') in
        match instr with
            |"help" -> begin
                print_string "Help.\n";
                print_string help_string;
                env
            end

            |"quit"  -> begin
                print_string "Quit.\n";
                let env' = {env with exit = true} in
                env'
            end

            |"show"  -> begin
                Printf.printf "- Context:\n%s\n" (Context.to_string env.context);
                print_string "- Generation settings:\n";
                Printf.printf "    generation shape: ";
                let _ =
                match env.generation_shape with
                    |BudGrammar.Hook -> Printf.printf "hook"
                    |BudGrammar.Synchronous -> Printf.printf "synchronous"
                    |BudGrammar.Stratum -> Printf.printf "stratum"
                in ();
                Printf.printf "\n    initial color: %s\n" env.initial_color;
                Printf.printf "    steps: %d\n" (env.nb_steps);
                Printf.printf "- Patterns:\n";
                env.colored_patterns |> List.iter
                    (fun cpat ->
                        Printf.printf "%s\n"
                            (BudGrammar.colored_element_to_string MultiPattern.to_string cpat));
                print_string "- Generated phrase: ";
                if Option.is_some env.result then begin
                    Printf.printf "%s\n" (MultiPattern.to_string (Option.get env.result));
                    let ar = MultiPattern.arity (Option.get env.result)
                    and len = MultiPattern.length (Option.get env.result) in
                    Printf.printf "arity: %d; length: %d\n" ar len
                end
                else
                    print_string "no generated phrase.\n";
                print_string "- Current file name: ";
                if Option.is_some env.file_name then
                    Printf.printf "%s\n" (Option.get env.file_name)
                else
                    print_string "no file name.\n";
                env
            end

            |"root" -> begin
                print_string "Set root.\n";
                try
                    let str = List.nth cmd' 1 in
                    let str = Tools.remove_blank_characters str in
                    let root = int_of_string str in
                    if (0 <= root) && (root < 128) then begin
                        let env' = {env with context = Context.set_root env.context root} in
                        Printf.printf "Root note set to %d.\n" root;
                        env'
                    end
                    else begin
                        print_string "Error: the root note must be between 0 and 127.\n";
                        env
                    end
                with
                    |_ -> begin
                        print_string "Error: input format. Integer expected.\n";
                        env
                    end
            end

            |"tempo" -> begin
                print_string "Set tempo.\n";
                try
                    let str = List.nth cmd' 1 in
                    let str = Tools.remove_blank_characters str in
                    let tempo = int_of_string str in
                    if 1 <= tempo then begin
                        let env' = {env with context = Context.set_tempo env.context tempo} in
                        Printf.printf "Tempo set to %d.\n" tempo;
                        env'
                    end
                    else begin
                        print_string "Error: the tempo must be 1 or more.\n";
                        env
                    end
                with
                    |_ -> begin
                        print_string "Error: input format. Integer expected.\n";
                        env
                    end
            end

            |"scale" -> begin
                print_string "Set scale.\n";
                try
                    let str = List.nth cmd' 1 in
                    let scale = Scale.from_string str in
                    if (Scale.is_scale scale) && Scale.nb_steps_by_octave scale = 12 then begin
                        let env' = {env with context = Context.set_scale env.context scale} in
                        Printf.printf "Scale set to %s.\n" (Scale.to_string scale);
                        env'
                    end
                    else begin
                        Printf.printf "Error: scale %s incorrect.\n" (Scale.to_string scale);
                        print_string "The octave must have 12 steps and the scale must have at \
                            least 1 note.\n";
                        env
                    end
                with
                    |_ -> begin
                        print_string "Error: input format. Integers expected.\n";
                        env
                    end
            end

            |"shape" -> begin
                print_string "Set generation shape.\n";
                try
                    let str = List.nth cmd' 1 in
                    let str = Tools.remove_blank_characters str in
                    match str with
                        |"hook" -> begin
                            let env' = {env with generation_shape = BudGrammar.Hook} in
                            Printf.printf "Generation shape set to hook.\n";
                            env'
                        end
                        |"synchronous" -> begin
                            let env' = {env with generation_shape = BudGrammar.Synchronous} in
                            Printf.printf "Generation shape set to synchronous.\n";
                            env'
                        end
                        |"stratum" -> begin
                            let env' = {env with generation_shape = BudGrammar.Stratum} in
                            Printf.printf "Generation shape set to stratum.\n";
                            env'
                        end
                        |_ -> begin
                            Printf.printf "Error: shape name incorrect.\n";
                            Printf.printf "Name must be hook, synchronous, or stratum.\n";
                            env
                        end
                with
                    |_ -> begin
                        print_string "Error: input format. String expected.\n";
                        env
                end
            end

            |"steps" -> begin
                print_string "Set number of steps.\n";
                try
                    let str = List.nth cmd' 1 in
                    let str = Tools.remove_blank_characters str in
                    let nb_steps = int_of_string str in
                    if 0 <= nb_steps then begin
                        let env' = {env with nb_steps = nb_steps} in
                        Printf.printf "Number of steps set to %d.\n" nb_steps;
                        env'
                    end
                    else begin
                        print_string "Error: the number of steps must be 0 or more.\n";
                        env
                    end
                with
                    |_ -> begin
                        print_string "Error: input format. Integer expected.\n";
                        env
                    end
            end

            |"add" -> begin
                print_string "Add pattern.\n";
                try
                    let str = List.nth cmd' 1 in
                    let cpat = BudGrammar.colored_element_from_string
                        MultiPattern.from_string str in
                    let mpat = BudGrammar.get_element cpat in
                    if MultiPattern.is_multi_pattern mpat then begin
                        let m = multiplicity env
                        and m' = MultiPattern.multiplicity mpat in
                        if (Option.is_none m) || ((Option.get m) = m') then begin
                            if (BudGrammar.is_colored_element
                                (MultiPattern.operad m') cpat) then begin
                                let env' = {env with
                                    colored_patterns = cpat :: env.colored_patterns}
                                in
                                env'
                            end
                            else begin
                                print_string "Error: inconsistent colors.\n";
                                env
                            end
                        end
                        else begin
                            print_string "Error: this pattern has not the good multiplicity.\n";
                            env
                        end
                    end
                    else begin
                        print_string "Error: this is a not a well-formed multi-pattern.\n";
                        env
                    end
                with
                    |_ -> begin
                        print_string "Error: input format. Colored multi-pattern expected.\n";
                        env
                    end
            end

            |"generate" -> begin
                if env.colored_patterns <> [] then begin
                    let m = MultiPattern.multiplicity
                        (BudGrammar.get_element (List.hd env.colored_patterns)) in
                    let budg = BudGrammar.create (MultiPattern.operad m)
                        env.colored_patterns env.initial_color in
                    let result = BudGrammar.random_generator budg env.nb_steps
                        env.generation_shape in
                    let g = BudGrammar.get_element result in
                    let env' = {env with result = Some g} in
                    print_string "A phrase has been generated.\n";
                    env'
                end
                else begin
                    print_string
                        "Error: generation impossible, there is no generator.\n";
                    env
                end
            end

            |"write" -> begin
                if Option.is_some env.result then begin
                    Sys.command ("mkdir -p " ^ path_results);
                    let file_name = Printf.sprintf "%s/%s%s"
                        path_results prefix_result (date_string ()) in
                    let env' = {env with file_name = Some file_name} in
                    let ok = create_abc_file env' in
                    if ok then
                        print_string "The abc file has been generated.\n"
                    else
                        print_string "Error: the abc file has not been generated.\n";
                    let ok = create_score_file env' in
                    if ok then
                        print_string "The ps file has been generated.\n"
                    else
                        print_string "Error: the ps file has not been generated.\n";
                    let ok = create_midi_file env' in
                    if ok then
                        print_string "The midi file has been generated.\n"
                    else
                        print_string "Error: the midi file has not been generated.\n";
                    env'
                end
                else begin
                    print_string "There is no generated phrase.\n";
                    env
                end
            end

            |"play" -> begin
                if (Option.is_some env.file_name) then
                    let ok = play_phrase env in
                    if ok then
                        print_string "Phrase played.\n"
                    else
                        print_string "Error: the phrase cannot be played.\n";
                else
                    print_string "The midi file has not been written, play is impossible.\n";
                env
            end

            |_ -> begin
                print_string "Error: unknown command.\n";
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

