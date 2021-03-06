(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020, apr. 2021
 *)

(* Names for paths. *)
type path = string

(* Names for multi-patterns and colored multi-patterns. *)
type name = string

(* The different possible degree monoids. *)
type degree_monoid =
    |AddInt
    |Cyclic of int
    |Max of int

(* All the possible program instructions. *)
type instruction =
    |Show
    |Write of name * path
    |Play of name
    |SetScale of Scale.scale
    |SetRoot of Context.midi_note
    |SetTempo of int
    |SetSounds of int list
    |SetMonoidAddInt
    |SetMonoidCyclic of int
    |SetMonoidMax of int
    |MultiPattern of name * MultiPattern.multi_pattern
    |Mirror of name * name
    |Concatenate of name * (name list)
    |Repeat of name * name * int
    |Stack of name * (name list)
    |PartialCompose of name * name * int * name
    |FullCompose of name * name * (name list)
    |HomogeneousCompose of name * name * name
    |Colorize of name * name * BudGrammar.color * (BudGrammar.color list)
    |Generate of name * BudGrammar.generation_shape * int * BudGrammar.color * (name list)

(* A program is a list of instructions. *)
type program = instruction list

(* The state is the internal memory during the execution of a program. *)
type state = {
    context : Context.context;
    midi_sounds : int list;
    degree_monoid : degree_monoid;
    multi_patterns : (string * MultiPattern.multi_pattern) list;
    colored_multi_patterns : (string * MultiPattern.colored_multi_pattern) list
}

(* Exception raised when a dynamic error is encountered. *)
exception ExecutionError of string

(* Returns the default midi sound (Acoustic Grand Piano). *)
let default_midi_sound = 0

(* Returns the extension of the file containing commands for the generation. *)
let extension = ".bmb"

(* The relative path of the directory containing the generated temporary results. *)
let path_results = "Outputs"

(* The prefix of all the generated temporary result files. *)
let prefix_result = "Phrase_"

(* Returns the initial state. *)
let initial_state =
    {context = Context.create Scale.minor_harmonic 57 192;
    midi_sounds = [];
    degree_monoid = AddInt;
    multi_patterns = [];
    colored_multi_patterns = []}

(* Returns the degree monoid of the state st. *)
let state_to_degree_monoid st =
    match st.degree_monoid with
        |AddInt -> DegreeMonoid.add_int
        |Cyclic k -> DegreeMonoid.cyclic k
        |Max z -> DegreeMonoid.max z

(* Returns a string representing the degree monoid dm. *)
let degree_monoid_to_string dm =
    match dm with
        |AddInt -> "Z"
        |Cyclic k -> Printf.sprintf "Z_%d" k
        |Max z -> Printf.sprintf "M_%d" z

(* Returns a string representing the state st. *)
let state_to_string st =
    Printf.sprintf
        "# Context:\n%s\n\
         # MIDI sounds:\n%s\n\
         # Monoid:\n%s\n\
         # Multi-patterns:\n%s\n\
         # Colored multi-patterns:\n%s"
        (Context.to_string st.context)
        ("    " ^ (Tools.list_to_string string_of_int " " st.midi_sounds))
        ("    " ^ (degree_monoid_to_string st.degree_monoid))
        ("    " ^ (Tools.list_to_string
            (fun (name, mpat) ->
                Printf.sprintf "%s = [multiplicity = %d, length = %d, arity = %d] %s"
                name
                (MultiPattern.multiplicity mpat)
                (MultiPattern.length mpat)
                (MultiPattern. arity mpat)
                (MultiPattern.to_string mpat))
            "\n    "
            st.multi_patterns))
        ("    " ^ (Tools.list_to_string
            (fun (name, cpat) ->
                Printf.sprintf "%s = %s" name
                    (BudGrammar.colored_element_to_string MultiPattern.to_string cpat))
            "\n    "
            st.colored_multi_patterns))

(* Tests if str is a multi-pattern, a colored multi-pattern, or a color name. *)
let is_name str =
    let len = String.length str in
    if len = 0 then
        false
    else
        Tools.interval 0 (len - 1) |> List.for_all
            (fun i ->
                let a = String.get str i in
                ('a' <= a && a <= 'z') ||  ('A' <= a && a <= 'Z')
                    ||  ('0' <= a && a <= '9') || a = '_')

(* Returns an option on the multi-pattern of name name in the state st. If there is no such
 * multi-pattern, None is returned. *)
let multi_pattern_with_name st name =
    List.assoc_opt name st.multi_patterns

(* Returns an option on the colored multi-pattern of name name in the state st. If there is
 * no such colored multi-pattern, None is returned. *)
let colored_multi_pattern_with_name env name =
    List.assoc_opt name env.colored_multi_patterns

(* Returns the state obtained by adding the multi-pattern mpat with the name name. If there
 * is already a multi-pattern with this name, it is overwritten. *)
let add_multi_pattern st name mpat =
    let new_lst = (name, mpat) :: (List.remove_assoc name st.multi_patterns) in
    {st with multi_patterns = new_lst}

(* Returns the state obtained by adding the colored multi-pattern cpat with the name
 * name. If there is already a colored multi-pattern with this name, it is overwritten. *)
let add_colored_multi_pattern st name cpat =
    let new_lst = (name, cpat) :: (List.remove_assoc name st.colored_multi_patterns) in
    {st with colored_multi_patterns = new_lst}

(* Create an ABC file, a postscript file, and a MIDI file of the multi-pattern mpat from the
 * state st. All the generated files have as name file_name, augmented with their adequate
 * extension. Returns true if the creation is possible and false otherwise. *)
let create_files st mpat file_name =
    let file_name_abc = file_name ^ ".abc" in
    let file_name_ps = file_name ^ ".ps" in
    let file_name_mid = file_name ^ ".mid" in
    if Sys.file_exists file_name_abc || Sys.file_exists file_name_ps
            || Sys.file_exists file_name_mid then
        false
    else begin
        let m = MultiPattern.multiplicity mpat in
        let diff_m = m - List.length st.midi_sounds in
        let midi_sounds = if diff_m <= 0 then
            st.midi_sounds
        else
            List.append st.midi_sounds (List.init diff_m (fun _ -> default_midi_sound))
        in
        try
            let str_abc = ABCNotation.complete_abc_string st.context midi_sounds mpat in
            let file_abc = open_out file_name_abc in
            Printf.fprintf file_abc "%s\n" str_abc;
            close_out file_abc;
            Printf.sprintf "abcm2ps %s -O %s &> /dev/null" file_name_abc file_name_ps
                |> Sys.command |> ignore;
            Printf.sprintf "abc2midi %s -o %s &> /dev/null" file_name_abc file_name_mid
                |> Sys.command |> ignore;
            true
        with
            |ABCNotation.Error -> false
    end

(* Plays the phrase from the state st. Returns true if the playing is possible and false
 * otherwise. *)
let play_phrase st mpat =
    if not (Sys.file_exists path_results) then
        Sys.command ("mkdir -p " ^ path_results) |> ignore
    else
        ();
    let file_name = Printf.sprintf "%s/%s%s"
        path_results prefix_result (Tools.time_string ()) in
    let err = create_files st mpat file_name in
    if not err then
        false
    else
        let file_name_mid = file_name ^ ".mid" in
        let err = Printf.sprintf "timidity %s &> /dev/null" file_name_mid |> Sys.command in
        not (Tools.int_to_bool err)

(* Executes the instruction instr on the state st and returns the new state after the
 * execution of instr. Produces also the specified side effect by instr. *)
let execute_instruction instr st =
    match instr with
        |Show -> begin
            Tools.print_information "Current environment:";
            Tools.print_information (state_to_string st);
            st
        end
        |Write (mpat_name, file_name) -> begin
            let mpat = multi_pattern_with_name st mpat_name in
            if Option.is_none mpat then
                raise (ExecutionError "Unknown multi-pattern name.");
            let ok = create_files st (Option.get mpat) file_name in
            if not ok then
                raise (ExecutionError "Error in file creations.");
            Printf.sprintf "The files %s has been generated." file_name
                |> Tools.print_information;
            st
        end
        |Play mpat_name -> begin
            let mpat = multi_pattern_with_name st mpat_name in
            if Option.is_none mpat then
                raise (ExecutionError "Unknown multi-pattern name.");
            Tools.print_information "Playing phrase...";
            let ok = play_phrase st (Option.get mpat) in
            if not ok then
                raise (ExecutionError "Error in playing.");
            Tools.print_information "Phrase played.";
            st
        end
        |SetScale scale -> begin
            if not (Scale.is_valid scale) then
                raise (ExecutionError "This is not a scale.");
            if not ((Scale.nb_steps_by_octave scale) = 12) then
                raise (ExecutionError "This is not a 12-TET scale");
            let st' = {st with context = Context.set_scale st.context scale} in
            Printf.sprintf "Scale set to %s." (Scale.to_string scale)
                |> Tools.print_information;
            st'
        end
        |SetRoot midi_note -> begin
            if not ((0 <= midi_note) && (midi_note < 128)) then
                raise (ExecutionError "This is not a MIDI note.");
            let st' = {st with context = Context.set_root st.context midi_note} in
            Printf.sprintf "Root note set to %d." midi_note |> Tools.print_information;
            st'
        end
        |SetTempo tempo -> begin
            if not (tempo >= 1) then
                raise (ExecutionError "This is not a valid tempo.");
            let st' = {st with context = Context.set_tempo st.context tempo} in
            Printf.sprintf "Tempo set to %d." tempo |> Tools.print_information;
            st'
        end
        |SetSounds midi_sounds -> begin
            if midi_sounds |> List.exists (fun s -> s < 0 || s > 127) then
                raise (ExecutionError "These MIDI sounds are not correct.");
            let st' = {st with midi_sounds = midi_sounds} in
            Printf.sprintf "MIDI sounds set to %s."
                (Tools.list_to_string string_of_int " " midi_sounds)
                |> Tools.print_information;
            st'
        end
        |SetMonoidAddInt -> begin
            let st' = {st with degree_monoid = AddInt} in
            Printf.sprintf "Degree monoid set to %s." (degree_monoid_to_string AddInt)
                |> Tools.print_information;
            st'
        end
        |SetMonoidCyclic k -> begin
            if k <= 0 then
                raise (ExecutionError "The order of the cyclic monoid is not correct.");
            let st' = {st with degree_monoid = Cyclic k} in
            Printf.sprintf "Degree monoid set to %s." (degree_monoid_to_string (Cyclic k))
                |> Tools.print_information;
            st'
        end
        |SetMonoidMax z -> begin
            let st' = {st with degree_monoid = Max z} in
            Printf.sprintf "Degree monoid set to %s." (degree_monoid_to_string (Max z))
                |> Tools.print_information;
            st'
        end
        |MultiPattern (name, mpat) -> begin
            if not (is_name name) then
                raise (ExecutionError "Bad multi-pattern name.");
            if not (MultiPattern.is_valid mpat) then
                raise (ExecutionError "Bad multi-pattern.");
            if not (MultiPattern.is_on_degree_monoid (state_to_degree_monoid st) mpat) then
                    raise (ExecutionError "Multi-pattern not on degree monoid.");
            let st' = add_multi_pattern st name mpat in
            Tools.print_information "Multi-pattern added.";
            st'
        end
        |Mirror (res_name, mpat_name) -> begin
            if not (is_name res_name) then
                raise (ExecutionError "Bad multi-pattern name.");
            let mpat = multi_pattern_with_name st mpat_name in
            if Option.is_none mpat then
                raise (ExecutionError "Unknown multi-pattern name.");
            let res = MultiPattern.mirror (Option.get mpat) in
            let st' = add_multi_pattern st res_name res in
            Tools.print_information "Mirror computed.";
            st'
        end
        |Concatenate (res_name, mpat_names_lst) -> begin
            if not (is_name res_name) then
                raise (ExecutionError "Bad multi-pattern name.");
            if mpat_names_lst = [] then
                raise (ExecutionError "Empty list of multi-patterns.");
            let mpat_lst = mpat_names_lst |> List.map (multi_pattern_with_name st) in
            if mpat_lst |> List.exists Option.is_none then
                raise (ExecutionError "Unknown multi-pattern name.");
            let mpat_lst' = mpat_lst |> List.map Option.get in
            let m = MultiPattern.multiplicity (List.hd mpat_lst') in
            if mpat_lst' |> List.exists (fun mpat -> MultiPattern.multiplicity mpat <> m)
                    then
                raise (ExecutionError "Bad multiplicity of multi-patterns.");
            let res = MultiPattern.concatenate_list mpat_lst' in
            let st' = add_multi_pattern st res_name res in
            Tools.print_information"Concatenation computed.";
            st'
        end
        |Repeat (res_name, mpat_name, k) -> begin
            if not (is_name res_name) then
                raise (ExecutionError "Bad multi-pattern name.");
            let mpat = multi_pattern_with_name st mpat_name in
            if Option.is_none mpat then
                raise (ExecutionError "Unknown multi-pattern name.");
            if k <= 0 then
                raise (ExecutionError "Bad number of repetitions.");
            let res = MultiPattern.repeat (Option.get mpat) k in
            let st' = add_multi_pattern st res_name res in
            Tools.print_information "Repetition computed.";
            st'
        end
        |Stack (res_name, mpat_names_lst) -> begin
            if not (is_name res_name) then
                raise (ExecutionError "Bad multi-pattern name.");
            if mpat_names_lst = [] then
                raise (ExecutionError "Empty list of multi-patterns.");
            let mpat_lst = mpat_names_lst |> List.map (multi_pattern_with_name st) in
            if mpat_lst |> List.exists Option.is_none then
                raise (ExecutionError "Unknown multi-pattern name.");
            let mpat_lst' = mpat_lst |> List.map Option.get in
            let ar = MultiPattern.arity (List.hd mpat_lst') in
            if mpat_lst' |> List.exists (fun mpat -> MultiPattern.arity mpat <> ar) then
                raise (ExecutionError "Bad arity of multi-patterns.");
            let len = MultiPattern.length (List.hd mpat_lst') in
            if mpat_lst' |> List.exists (fun mpat -> MultiPattern.length mpat <> len) then
                raise (ExecutionError "Bad length of multi-patterns.");
            let res = MultiPattern.stack_list mpat_lst' in
            let st' = add_multi_pattern st res_name res in
            Tools.print_information "Stack computed.";
            st'
        end
        |PartialCompose (res_name, mpat_name_1, pos, mpat_name_2) -> begin
            if not (is_name res_name) then
                raise (ExecutionError "Bad multi-pattern name.");
            let mpat_1 = multi_pattern_with_name st mpat_name_1 in
            if Option.is_none mpat_1 then
                raise (ExecutionError "Unknown multi-pattern name.");
            let mpat_2 = multi_pattern_with_name st mpat_name_2 in
            if Option.is_none mpat_2 then
                raise (ExecutionError "Unknown multi-pattern name.");
            if MultiPattern.multiplicity (Option.get mpat_1)
                    <> MultiPattern.multiplicity (Option.get mpat_2) then
                raise (ExecutionError "Bad multiplicity of multi-patterns.\n");
            if pos < 1 || pos > MultiPattern.arity (Option.get mpat_1) then
                raise (ExecutionError "Bad partial composition position.");
            let res = MultiPattern.partial_composition (state_to_degree_monoid st)
                (Option.get mpat_1) pos (Option.get mpat_2) in
            let st' = add_multi_pattern st res_name res in
            Tools.print_information "Partial composition computed.";
            st'
        end
        |FullCompose (res_name, mpat_name, mpat_names_lst) -> begin
            if not (is_name res_name) then
                raise (ExecutionError "Bad multi-pattern name.");
            let mpat = multi_pattern_with_name st mpat_name in
            if Option.is_none mpat then
                raise (ExecutionError "Unknown multi-pattern name.");
            let mpat_lst = mpat_names_lst |> List.map (multi_pattern_with_name st) in
            if mpat_lst |> List.exists Option.is_none then
                raise (ExecutionError "Unknown multi-pattern name.");
            let mpat_lst' = mpat_lst |> List.map Option.get in
            let m = MultiPattern.multiplicity (List.hd mpat_lst') in
            if mpat_lst' |> List.exists (fun mpat -> MultiPattern.multiplicity mpat <> m)
                    then
                raise (ExecutionError "Bad multiplicity of multi-patterns.\n");
            let res = MultiPattern.full_composition
                (state_to_degree_monoid st) (Option.get mpat) mpat_lst' in
            let st' = add_multi_pattern st res_name res in
            Tools.print_information "Full composition computed.";
            st'
        end
        |HomogeneousCompose (res_name, mpat_name_1, mpat_name_2) -> begin
            if not (is_name res_name) then
                raise (ExecutionError "Bad multi-pattern name.");
            let mpat_1 = multi_pattern_with_name st mpat_name_1 in
            if Option.is_none mpat_1 then
                raise (ExecutionError "Unknown multi-pattern name.");
            let mpat_2 = multi_pattern_with_name st mpat_name_2 in
            if Option.is_none mpat_2 then
                raise (ExecutionError "Unknown multi-pattern name.");
            if MultiPattern.multiplicity (Option.get mpat_1)
                    <> MultiPattern.multiplicity (Option.get mpat_2) then
                raise (ExecutionError "Bad multiplicity of multi-patterns.\n");
            let res = MultiPattern.homogeneous_composition
                (state_to_degree_monoid st) (Option.get mpat_1) (Option.get mpat_2) in
            let st' = add_multi_pattern st res_name res in
            Tools.print_information "Homogeneous composition computed.";
            st'
        end
        |Colorize (res_name, mpat_name, out_color, in_colors) -> begin
            if not (is_name res_name) then
                raise (ExecutionError "Bad multi-pattern name.");
            let mpat = multi_pattern_with_name st mpat_name in
            if Option.is_none mpat then
                raise (ExecutionError "Unknown multi-pattern name.");
            if List.length in_colors <> (MultiPattern.arity (Option.get mpat)) then
                raise (ExecutionError "Bad number of input colors.");
            let cpat = BudGrammar.create_colored_element out_color (Option.get mpat)
                in_colors in
            let st' = add_colored_multi_pattern st res_name cpat in
            Tools.print_information "Colored multi-pattern added.";
            st'
        end
        |Generate (res_name, shape, size, color, cpat_names_lst) -> begin
            if not (is_name res_name) then
                raise (ExecutionError "Bad multi-pattern name.");
            if size < 0 then
                raise (ExecutionError "Bad size for the generation.");
            if not (is_name color) then
                raise (ExecutionError "Bad color name.");
            let cpat_lst = cpat_names_lst |> List.map (colored_multi_pattern_with_name st)
            in
            if cpat_lst |> List.exists Option.is_none then
                raise (ExecutionError "Unknown colored multi-pattern name.");
            let cpat_lst' = cpat_lst |> List.map Option.get in
            let m = MultiPattern.multiplicity (BudGrammar.get_element (List.hd cpat_lst'))
            in
            if cpat_lst' |> List.exists
                    (fun cpat ->
                        MultiPattern.multiplicity (BudGrammar.get_element cpat) <> m)
                    then
                raise (ExecutionError "Bad multiplicity of colored multi-patterns.\n");
            let res = Generation.from_colored_multi_patterns
                (Generation.create_parameters size shape)
                color
                (state_to_degree_monoid st)
                cpat_lst' in
            let st' = add_multi_pattern st res_name res in
            Tools.print_information "Multi-pattern generated.";
            st'
        end

(* Executes the program prgm. *)
let execute prgm =
    try
        Tools.print_information "Execution...";
        prgm |> List.fold_left
            (fun res instr -> execute_instruction instr res) initial_state
            |> ignore;
        Tools.print_success "End of execution."
    with
        |ExecutionError msg ->
            Printf.sprintf "Execution error: %s" msg |> Tools.print_error

