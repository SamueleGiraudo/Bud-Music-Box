(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* The state is the internal memory during the execution of a program. It contains also
 * information about the last considered instruction (by the fields success and message. *)
type states = {
    path_bmb: string;
    path_mid: string option;
    scale: Scales.scales option;
    root: MIDI.notes option;
    tempo: int option;
    midi_programs: MIDI.programs list;
    degree_monoid: DegreeMonoids.degree_monoids option;
    multi_patterns: (Programs.names * MultiPatterns.multi_patterns) list;
    colored_multi_patterns: (Programs.names * MultiPatterns.colored_multi_pattern) list;
    success: bool;
    message: string option
}

(* Returns the state which is equal to the state st but reporting a failure with message
 * msg. *)
let set_fail_message st msg =
    {st with success = false; message = Some msg}

(* Returns the state which is equal to the state st but reporting a success with message
 * msg. *)
let set_success_message st msg =
    {st with success = true; message = Some msg}

(* Returns the state which is equal to the state st but reporting a success without any
 * message. *)
let success st =
    {st with success = true; message = None}

(* Returns the state which is equal to the state st but with path to a MIDI file equal to
 * path_mid. *)
let set_path_mid st path_mid =
    {st with path_mid = Some path_mid}

(* Returns the empty state having path_bmb as path to the bmb program file. *)
let empty_state path_bmb =
    {
        path_bmb = path_bmb;
        path_mid = None;
        scale = None;
        root = None;
        tempo = None;
        midi_programs = [];
        degree_monoid = None;
        multi_patterns = [];
        colored_multi_patterns = [];
        success = true;
        message = None
    }

(* Returns a string representing the state st. *)
let state_to_string st =
    Printf.sprintf
        "# Scale:\n%s\n\
         # MIDI root note:\n%s\n\
         # Tempo:\n%s bpm\n\
         # MIDI sounds:\n%s\n\
         # Monoid:\n%s\n\
         # Multi-patterns:\n%s\n\
         # Colored multi-patterns:\n%s"
        (st.scale |> Options.map Scales.to_string |> Options.value "Not set."
            |> Strings.indent 4)
        (st.root |> Options.map MIDI.note_to_string |> Options.value "Not set."
            |> Strings.indent 4)
        (st.tempo |> Options.map string_of_int |> Options.value "Not set."
            |> Strings.indent 4)
        (Strings.indent 4 (Strings.from_list MIDI.program_to_string " " st.midi_programs))
        (st.degree_monoid |> Options.map DegreeMonoids.name |> Options.value "Not set."
            |> Strings.indent 4)
        (Strings.indent 4 (Strings.from_list
            (fun (name, mpat) ->
                Printf.sprintf "%s = [multiplicity = %d, length = %d, arity = %d] %s"
                name
                (MultiPatterns.multiplicity mpat)
                (MultiPatterns.length mpat)
                (MultiPatterns. arity mpat)
                (MultiPatterns.to_string mpat))
            "\n"
            st.multi_patterns))
        (Strings.indent 4 (Strings.from_list
            (fun (name, cpat) ->
                Printf.sprintf "%s = %s" name
                    (BudGrammars.colored_element_to_string MultiPatterns.to_string cpat))
            "\n"
            st.colored_multi_patterns))
        |> Strings.indent 4

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
 * state st. Returns the status obtained from st to report failure or success
 * information. *)
let create_files st mpat =
    let path_abc = Paths.remove_extension st.path_bmb ^ ".abc" |> Paths.new_distinct in
    let path_ps = Paths.remove_extension st.path_bmb ^ ".ps" |> Paths.new_distinct in
    let path_mid = Paths.remove_extension st.path_bmb ^ ".mid" |> Paths.new_distinct in
    if Option.is_none st.scale then
        set_fail_message st "Scale not specified."
    else if Option.is_none st.root then
        set_fail_message st "Root note not specified."
    else if Option.is_none st.tempo then
        set_fail_message st "Tempo not specified."
    else if Option.is_none st.degree_monoid then
        set_fail_message st "Degree monoid not specified."
    else if List.length st.midi_programs < MultiPatterns.multiplicity mpat then
        set_fail_message st "MIDI programs insufficiently specified."
    else
        let ct =
            Contexts.make
                (Option.get st.scale)
                (Option.get st.root)
                (Option.get st.tempo)
                st.midi_programs
        in
        let str_abc = ABCNotation.complete_abc_string ct mpat in
        if Option.is_none str_abc then
            set_fail_message st "Degrees outside MIDI note range."
        else begin
            let file_abc = open_out path_abc in
            Printf.fprintf file_abc "%s\n" (Option.get str_abc);
            close_out file_abc;
            Printf.sprintf "abcm2ps %s -O %s &> /dev/null" path_abc path_ps
            |> Sys.command |> ignore;
            Printf.sprintf "abc2midi %s -o %s &> /dev/null" path_abc path_mid
            |> Sys.command |> ignore;
            let st' = set_path_mid st path_mid in
            success st'
        end

(* Plays the track from the state st and returns the status obtained from st to report
* failure or success information. *)
let play_track st mpat = 
    let st' = create_files st mpat in
    if not st'.success then
        st'
    else if Option.is_none st'.path_mid then
        set_fail_message st' "Missing MIDI file."
    else
        let err =
            Printf.sprintf "timidity %s &> /dev/null" (Option.get st'.path_mid)
            |> Sys.command
        in
        if err <> 0 then
            set_fail_message st' "Timidity set_fail_messageure."
        else
            success st'

(* Executes the instruction instr on the state st and returns the new state after the
 * execution of instr. The returned status report failure or success information about the
 * execution of instr. Produces also the specified side effect by instr. *)
let execute_instruction instr st =
    match instr with
        |Programs.Show -> begin
            Outputs.print_information "Current state:\n";
            Printf.printf "%s\n" (state_to_string st);
            set_success_message st "State printed."
        end
        |Programs.Write mpat_name ->
            let mpat = multi_pattern_with_name st mpat_name in
            if Option.is_none mpat then
                set_fail_message st "Unknown multi-pattern name."
            else
                let st' = create_files st (Option.get mpat) in
                if not st'.success then
                    st'
                else
                    set_success_message st' "Files generated."
        |Programs.Play mpat_name ->
            let mpat = multi_pattern_with_name st mpat_name in
            if Option.is_none mpat then
                set_fail_message st "Unknown multi-pattern name."
            else begin
                Outputs.print_information "Playing track...\n";
                let st' = play_track st (Option.get mpat) in
                if not st'.success then
                    st'
                else
                    set_success_message st' "Track played."
            end
        |Programs.SetScale scale ->
            if not (Scales.is_valid scale) then
                set_fail_message st "Not a scale."
            else if not ((Scales.nb_steps_by_octave scale) = 12) then
                set_fail_message st "Not a 12-TET scale."
            else
                let st' = {st with scale = Some scale} in
                set_success_message st' "Scale set."
        |Programs.SetRoot midi_note ->
            if not (MIDI.is_valid_note midi_note) then
                set_fail_message st "Invalid MIDI note code."
            else
                let st' = {st with root = Some midi_note} in
                set_success_message st' "Root note set."
        |Programs.SetTempo tempo ->
            if not (tempo >= 1) then
                set_fail_message st "Invalid tempo."
            else
                let st' = {st with tempo = Some tempo} in
                set_success_message st' "Tempo set."
        |Programs.SetSounds midi_programs ->
            if midi_programs |> List.exists (fun p -> not (MIDI.is_valid_program p)) then
                set_fail_message st "Invalid MIDI programs."
            else
                let st' = {st with midi_programs = midi_programs} in
                set_success_message st' "MIDI programs set."
        |Programs.SetDegreeMonoid dm ->
            let st' = {st with degree_monoid = Some dm} in
            set_success_message st' "Degree monoid set."
        |Programs.MultiPattern (name, mpat) ->
            if not (Files.is_name name) then
                set_fail_message st "Bad multi-pattern name."
            else if not (MultiPatterns.is_valid mpat) then
                set_fail_message st "Bad multi-pattern."
            else if Option.is_none st.degree_monoid then
                set_fail_message st "Degree monoid not specified."
            else
                let dm = Option.get st.degree_monoid in
                if not (MultiPatterns.is_on_degree_monoid dm mpat) then
                    set_fail_message st "Multi-pattern not on degree monoid."
                else
                    let st' = add_multi_pattern st name mpat in
                    set_success_message st' "Multi-pattern added."
        |Programs.Mirror (res_name, mpat_name) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else
                let mpat = multi_pattern_with_name st mpat_name in
                if Option.is_none mpat then
                    set_fail_message st "Unknown multi-pattern name."
                else
                    let res = MultiPatterns.mirror (Option.get mpat) in
                    let st' = add_multi_pattern st res_name res in
                    set_success_message st' "Mirror computed and added."
        |Programs.Inverse (res_name, mpat_name) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else
                let mpat = multi_pattern_with_name st mpat_name in
                if Option.is_none mpat then
                    set_fail_message st "Unknown multi-pattern name."
                else
                    let res = MultiPatterns.map Degrees.opposite (Option.get mpat) in
                    let st' = add_multi_pattern st res_name res in
                    set_success_message st' "Inverse computed and added."
        |Programs.Concatenate (res_name, mpat_names_lst) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else if mpat_names_lst = [] then
                set_fail_message st "Empty list of multi-patterns."
            else
                let mpat_lst = mpat_names_lst |> List.map (multi_pattern_with_name st) in
                if mpat_lst |> List.exists Option.is_none then
                    set_fail_message st "Unknown multi-pattern name."
                else
                    let mpat_lst' = mpat_lst |> List.map Option.get in
                    let m = MultiPatterns.multiplicity (List.hd mpat_lst') in
                    if mpat_lst'
                    |> List.exists (fun mpat -> MultiPatterns.multiplicity mpat <> m) then
                        set_fail_message st "Bad multiplicity of multi-patterns."
                    else
                        let res = MultiPatterns.concatenate_list mpat_lst' in
                        let st' = add_multi_pattern st res_name res in
                        set_success_message st' "Concatenation computed and added.";
        |Programs.Repeat (res_name, mpat_name, k) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else
                let mpat = multi_pattern_with_name st mpat_name in
                if Option.is_none mpat then
                    set_fail_message st "Unknown multi-pattern name."
                else if k <= 0 then
                    set_fail_message st "Bad number of repetitions."
                else
                    let res = MultiPatterns.repeat (Option.get mpat) k in
                    let st' = add_multi_pattern st res_name res in
                    set_success_message st' "Repetition computed and added.\n";
        |Programs.Stack (res_name, mpat_names_lst) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else if mpat_names_lst = [] then
                set_fail_message st "Empty list of multi-patterns."
            else
                let mpat_lst = mpat_names_lst |> List.map (multi_pattern_with_name st) in
                if mpat_lst |> List.exists Option.is_none then
                    set_fail_message st "Unknown multi-pattern name."
                else
                    let mpat_lst' = mpat_lst |> List.map Option.get in
                    let ar = MultiPatterns.arity (List.hd mpat_lst') in
                    if mpat_lst'
                    |> List.exists (fun mpat -> MultiPatterns.arity mpat <> ar) then
                        set_fail_message st "Bad arity of multi-patterns."
                    else
                        let len = MultiPatterns.length (List.hd mpat_lst') in
                        if mpat_lst'
                        |> List.exists (fun mpat -> MultiPatterns.length mpat <> len) then
                            set_fail_message st "Bad length of multi-patterns."
                    else
                        let res = MultiPatterns.stack_list mpat_lst' in
                        let st' = add_multi_pattern st res_name res in
                        set_success_message st' "Stack computed and added."
        |Programs.PartialCompose (res_name, mpat_name_1, pos, mpat_name_2) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else
                let mpat_1 = multi_pattern_with_name st mpat_name_1 in
                if Option.is_none mpat_1 then
                    set_fail_message st "Unknown multi-pattern name."
                else
                    let mpat_2 = multi_pattern_with_name st mpat_name_2 in
                    if Option.is_none mpat_2 then
                        set_fail_message st "Unknown multi-pattern name."
                    else
                        let mpat_1 = Option.get mpat_1 and mpat_2 = Option.get mpat_2 in
                        if MultiPatterns.multiplicity mpat_1 
                        <> MultiPatterns.multiplicity mpat_2 then
                        set_fail_message st "Bad multiplicity of multi-patterns.\n"
                    else if pos < 1 || pos > MultiPatterns.arity mpat_1 then
                        set_fail_message st "Bad partial composition position."
                    else if Option.is_none st.degree_monoid then
                        set_fail_message st "Degree monoid not specified."
                    else
                        let dm = Option.get st.degree_monoid in
                        let res = MultiPatterns.partial_composition dm mpat_1 pos mpat_2 in
                        let st' = add_multi_pattern st res_name res in
                        set_success_message st' "Partial composition computed and added."
        |Programs.FullCompose (res_name, mpat_name, mpat_names_lst) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else
                let mpat = multi_pattern_with_name st mpat_name in
                if Option.is_none mpat then
                    set_fail_message st "Unknown multi-pattern name."
                else
                    let mpat_lst =
                        mpat_names_lst |> List.map (multi_pattern_with_name st)
                    in
                    if mpat_lst |> List.exists Option.is_none then
                        set_fail_message st "Unknown multi-pattern name."
                    else
                        let mpat = Option.get mpat in
                        let mpat_lst' = mpat_lst |> List.map Option.get in
                        let m = MultiPatterns.multiplicity mpat in
                        if mpat_lst'
                        |> List.exists (fun mpat -> MultiPatterns.multiplicity mpat <> m)
                        then
                            set_fail_message st "Bad multiplicity of multi-patterns."
                        else if Option.is_none st.degree_monoid then
                            set_fail_message st "Degree monoid not specified."
                        else
                            let dm = Option.get st.degree_monoid in
                            let res = MultiPatterns.full_composition dm mpat mpat_lst' in
                            let st' = add_multi_pattern st res_name res in
                            set_success_message st' "Full composition computed and added."
        |Programs.HomogeneousCompose (res_name, mpat_name_1, mpat_name_2) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else
                let mpat_1 = multi_pattern_with_name st mpat_name_1 in
                if Option.is_none mpat_1 then
                    set_fail_message st "Unknown multi-pattern name."
                else
                    let mpat_2 = multi_pattern_with_name st mpat_name_2 in
                    if Option.is_none mpat_2 then
                        set_fail_message st "Unknown multi-pattern name."
                    else
                        let mpat_1 = Option.get mpat_1 and mpat_2 = Option.get mpat_2 in
                        if MultiPatterns.multiplicity mpat_1
                        <> MultiPatterns.multiplicity mpat_2 then
                            set_fail_message st "Bad multiplicity of multi-patterns."
                        else if Option.is_none st.degree_monoid then
                            set_fail_message st "Degree monoid not specified."
                        else
                            let dm = Option.get st.degree_monoid in
                            let res =
                                MultiPatterns.homogeneous_composition dm mpat_1 mpat_2
                            in
                            let st' = add_multi_pattern st res_name res in
                            set_success_message
                                st'
                                "Homogeneous composition computed and added."
        |Programs.Colorize (res_name, mpat_name, out_color, in_colors) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else
                let mpat = multi_pattern_with_name st mpat_name in
                if Option.is_none mpat then
                    set_fail_message st "Unknown multi-pattern name."
                else
                    let mpat = Option.get mpat in
                    if List.length in_colors <> MultiPatterns.arity mpat then
                        set_fail_message st "Bad number of input colors."
                    else
                        let cpat =
                            BudGrammars.make_colored_element out_color mpat in_colors
                        in
                        let st' = add_colored_multi_pattern st res_name cpat in
                        set_success_message st' "Colored multi-pattern added."
        |Programs.MonoColorize (res_name, mpat_name, out_color, in_color) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else
                let mpat = multi_pattern_with_name st mpat_name in
                if Option.is_none mpat then
                    set_fail_message st "Unknown multi-pattern name."
                else
                    let mpat = Option.get mpat in
                    let n = MultiPatterns.arity mpat in
                    let cpat =
                        BudGrammars.make_colored_element
                            out_color
                            mpat
                            (List.init n (Fun.const in_color))
                    in
                    let st' = add_colored_multi_pattern st res_name cpat in
                    set_success_message st' "Monocolored multi-pattern added.\n"
        |Programs.Generate (res_name, shape, size, color, cpat_names_lst) ->
            if not (Files.is_name res_name) then
                set_fail_message st "Bad multi-pattern name."
            else if size < 0 then
                set_fail_message st "Bad size for the generation."
            else if not (Files.is_name (BudGrammars.color_name color)) then
                set_fail_message st "Bad color name."
            else
                let cpat_lst =
                    cpat_names_lst
                    |> List.map (colored_multi_pattern_with_name st)
                in
                if cpat_lst |> List.exists Option.is_none then
                    set_fail_message st "Unknown colored multi-pattern name."
                else
                    let cpat_lst' = cpat_lst |> List.map Option.get in
                    let m =
                        MultiPatterns.multiplicity
                            (BudGrammars.get_element (List.hd cpat_lst'))
                    in
                    if cpat_lst'
                    |> List.exists
                        (fun cpat ->
                            MultiPatterns.multiplicity (BudGrammars.get_element cpat) <> m)
                    then
                        set_fail_message st "Bad multiplicity of colored multi-patterns."
                    else if Option.is_none st.degree_monoid then
                        set_fail_message st "Degree monoid not specified."
                    else
                        let dm = Option.get st.degree_monoid in
                        let res =
                            Generation.from_colored_multi_patterns
                                (Generation.make_parameters size shape)
                                color
                                dm
                                cpat_lst'
                        in
                        let st' = add_multi_pattern st res_name res in
                        set_success_message st' "Multi-pattern generated."

(* Executes the program prgm located in the program file of path path_bmb. This function
 * only produces the side effects prescribed by the program. *)
let execute prgm path_bmb =
    assert (Sys.file_exists path_bmb);
    Outputs.print_information "Execution...\n";
    prgm
    |> Programs.instructions
    |> List.fold_left
        (fun res instr ->
            let res = execute_instruction instr res in
            if Option.is_some res.message then
                (Option.get res.message) ^ "\n"
                |> if res.success then Outputs.print_success else Outputs.print_error;
            res)
        (empty_state path_bmb)
    |> ignore;
    Outputs.print_success "End of execution.\n"

(* Executes the program contained in the file of path path_bmb. *)
let execute_path path_bmb =
    assert (Sys.file_exists path_bmb);
    try
        let prgm = Files.path_to_program path_bmb in
        execute prgm path_bmb
    with
        |Lexer.Error ei ->
            Printf.sprintf "Syntax error: %s\n" (Lexer.error_information_to_string ei)
            |> Outputs.print_error

