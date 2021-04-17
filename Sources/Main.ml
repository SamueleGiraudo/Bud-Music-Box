(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, may 2019, aug. 2019, dec. 2019, jan. 2020
 * apr. 2020, may 2020, oct. 2020, apr. 2021
 *)

let name = "Bud Music Box"
let logo = "8/\\/\\8"
(* let version = "0.01"
 * let version = "0.10"
 * let version = "0.11"
 * let version = "0.111"
 * let version = "0.1111"
 * let version = "1.001"
 *)
let version = "1.011" and version_date = "2021-04-17"
let author = "Samuele Giraudo"
let email = "samuele.giraudo@u-pem.fr"

let information =
    Printf.sprintf "%s\n%s\nCopyright (C) 2019--2021 %s\nWritten by %s [%s]\n\
        Version: %s (%s)\n"
        logo name author author email version version_date

let help_string =
    "Available arguments:\n"
        ^ "-v\n"
        ^ "    -> Print the version of the application.\n"
        ^ "-h\n"
        ^ "    -> Print the help.\n"
        ^ "-hi\n"
        ^ "    -> Print the help about the instruction set.\n"
        ^ "-f PATH\n"
        ^ (Printf.sprintf "    -> Interpret the file PATH having %s as extension.\n"
            Program.extension)

(* The name of the help file. *)
let help_file_path = "Help.md"

;;

if Tools.has_argument "-r" then
    Random.init 0
else
    Random.self_init ();

if Tools.has_argument "-v" then begin
    print_string information
end
else if Tools.has_argument "-h" then begin
    print_string "Help:\n\n";
    print_string help_string;
end
else if Tools.has_argument "-hi" then begin
    print_string "Help on instructions:\n\n";
    let help_file = open_in help_file_path in
    print_string (Std.input_list help_file |> String.concat "\n")
end
else if Tools.has_argument "-f" then begin
    let path = Tools.next_arguments "-f" 1 in
    if path = [] then begin
        Tools.print_error "Error: a path must follow the -f argument.";
        exit 1
    end
    else begin
        let path = List.hd path in
        if not (Sys.file_exists path) then begin
            Tools.print_error (Printf.sprintf "Error: there is no file %s." path);
            exit 1
        end
        else if not (Tools.has_extension Program.extension path) then begin
            Tools.print_error (Printf.sprintf "Error: extension of file %s must be %s."
                path Program.extension);
            exit 1
        end
        else begin
            try
                let prgm = Lexer.value_from_file_path path Parser.program Lexer.read in
                Program.execute prgm
            with
                |Lexer.Error ei ->
                    Printf.printf "Syntax error: %s\n"
                        (Lexer.error_information_to_string ei);
            exit 0
        end
    end
end
else
    print_string "Use option -h to print help.\n";
exit 0

