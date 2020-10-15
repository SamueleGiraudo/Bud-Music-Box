(* Author: Samuele Giraudo
 * Creation: mar. 2019
 * Modifications: mar. 2019, apr. 2019, may 2019, aug. 2019, dec. 2019, jan. 2020
 * apr. 2020, may 2020, oct. 2020
 *)

let name = "Bud Music Box"
(* let version = "0.01"
 * let version = "0.10"
 * let version = "0.11"
 * let version = "0.111"
*)
let version = "0.1111"
let author = "Samuele Giraudo"
let email = "samuele.giraudo@u-pem.fr"

let information =
    Printf.sprintf "%s\nCopyright (C) 2019--2020 %s\nWritten by %s [%s]\nVersion: %s\n"
        name author author email version

let help_string =
    "Available arguments:\n"
        ^ "-v\n"
        ^ "    -> Print the version of the application.\n"
        ^ "-h\n"
        ^ "    -> Print the help.\n"
        ^ "-hi\n"
        ^ "    -> Print the help about the instruction set.\n"
        ^ "-i\n"
        ^ "    -> Launch the interpreter.\n"
        ^ "-f PATH\n"
        ^ (Printf.sprintf "    -> Interpret the file PATH having %s as extension.\n"
            Interpreter.extension)

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
end
else if has_argument "-h" then begin
    print_string "Help:\n\n";
    print_string help_string;
end
else if has_argument "-hi" then begin
    print_string "Help on instructions:\n\n";
    print_string Interpreter.help_string
end
else if has_argument "-i" then begin
    print_string "Interpreter\n";
    Interpreter.interaction_loop ()
end
else if has_argument "-f" then begin
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
end
else if Tools.has_argument "-ff" then begin
    let path = Tools.next_argument "-ff" in
    if Option.is_none path then begin
        print_string "Error: a path must follow the -f argument.\n";
        exit 1
    end
    else begin
        let path = Option.get path in
        if not (Sys.file_exists path) then begin
            Printf.printf "Error: there is no file %s.\n" path;
            exit 1
        end
        else begin
            Tools.interpret_file_path
                path
                Parser.program
                Lexer.read
                Program.execute
                (fun _ -> true);
            exit 0
        end
    end
end
else
    print_string "Use option -h to print help.\n";

exit 0;

