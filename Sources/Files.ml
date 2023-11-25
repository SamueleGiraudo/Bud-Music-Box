(* Author: Samuele Giraudo
 * Creation: nov. 2023
 * Modifications: nov. 2023
 *)

(* Returns the extension of the file containing commands for the generation. *)
let extension = ".bmb"

(* Tests if the character c is an alphabetic character. *)
let is_alpha_character c =
    ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z')

(* Tests if the character c is a number character. *)
let is_num_character c =
    '0' <= c && c <= '9'

(* Tests if the character c is a character allowed in aliases. *)
let is_plain_character c =
     is_alpha_character c || is_num_character c || c = '_' || c = '\''

(* Tests if str is a multi-pattern, a colored multi-pattern, or a color name. *)
let is_name str =
    String.length str >= 1 && not (is_num_character (String.get str 0))
    && String.for_all is_plain_character str

(* Returns the program specified by the Aclove file at path path. The exception
 * Lexer.Error is raised when there are syntax errors in the program. *)
let path_to_program path =
    Lexer.value_from_file_path path Parser.program Lexer.read

