(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, may 2019, aug. 2019, dec. 2019, jan. 2020
 * apr. 2020, may 2020, oct. 2020, apr. 2021, jul. 2022, aug. 2022, nov. 2023
 *)

let name = "Bud Music Box"

let logo = "|3^^|3"

(* let version = "0.01" *)
(* let version = "0.10" *)
(* let version = "0.11" *)
(* let version = "0.111" *)
(* let version = "0.1111" *)
(* let version = "1.001" *)
(* let version = "1.011" and version_date = "2021-04-17" *)
(*let version = "1.100" and version_date = "2022-08-10"*)
let version = "1.101" and version_date = "2023-11-25"

let author = "Samuele Giraudo"

(*let email = "samuele.giraudo@univ-eiffel.fr"*)
let email = "giraudo.samuele@uqam.fr"

let information =
    Printf.sprintf "%s\n%s\nCopyright (C) 2019--2023 %s\nWritten by %s [%s]\n\
        Version: %s (%s)\n"
        logo name author author email version version_date

(* Returns the help string about the arguments of the program. *)
let help_string =
      "Usage:\n    ./bmb [--help] [--version] [--seed N] --file PATH \nwhere:\n"
    ^ "    + `--help` prints the short help (the present text).\n"
    ^ "    + `--version` prints the version and other information.\n"
    ^ "    + `--seed N` sets N as the seed of the random generator.\n"
    ^ "    + `--file PATH` sets PATH as the path to the Bud Music Box program to consider, \
             contained in a " ^ Files.extension ^ " file.\n"

;;

(* Main expression. *)

(* Version. *)
if Arguments.exists "--version" then begin
    Outputs.print_success information;
    exit 0
end;

(* Help. *)
if Arguments.exists "--help" then begin
    Outputs.print_information help_string;
    exit 0
end;

(* Read the seed of the random generator. *)
let s =
    if Arguments.exists "--seed" then begin
        let arg_lst = Arguments.option_values "--seed" in
        if List.length arg_lst <> 1 then begin
            "Error: one option must follow the --seed argument.\n" |> Outputs.print_error;
            exit 1
        end
        else
            try
                int_of_string (List.hd arg_lst)
            with
                |_ -> begin
                    "Error: a nonnegative integer must follow the --seed argument.\n"
                    |> Outputs.print_error;
                    exit 1
                end
    end
    else
        (Unix.time () |> int_of_float) mod 8192
in
Printf.sprintf "Seed of the random generator set to %d.\n" s |> Outputs.print_information;

(* Tests if there is a single file path. *)
let arg_lst = Arguments.option_values "--file" in
if List.length arg_lst <> 1 then begin
    "Error: one path must follow the --file argument.\n" |> Outputs.print_error;
    exit 1
end;

(* The path of the file containing the program. *)
let path = List.hd arg_lst in

(* Checks the existence of the file at path path. *)
if Sys.file_exists path |> not then begin
    Printf.sprintf "Error: there is no file %s.\n" path |> Outputs.print_error;
    exit 1
end;

(* Checks if the file has the right extension. *)
if not (Paths.has_extension Files.extension path) then begin
    Printf.sprintf "Error: the file %s has not %s as extension.\n" path Files.extension
    |> Outputs.print_error;
    exit 1
end;

(* Considers the program and executes it. *)
Execution.execute_path path s;

exit 0

