(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020
 *)

let letter = ['a'-'z' 'A'-'Z' '_']
let digits = ['0'-'9']
let plain_character = letter | digits

let name = letter plain_character*
let integer = '-'? digits+

rule read = parse
    |' ' |'\t'
        {read lexbuf}
    |'\n'
        {Tools.next_line lexbuf; read lexbuf}
    |';'
        {Parser.SEMICOLON}
    |'*'
        {Parser.STAR}
    |"show"
        {Parser.SHOW}
    |"write"
        {Parser.WRITE}
    |"play"
        {Parser.PLAY}
    |"set_scale"
        {Parser.SET_SCALE}
    |"set_root"
        {Parser.SET_ROOT}
    |"set_tempo"
        {Parser.SET_TEMPO}
    |"set_sounds"
        {Parser.SET_SOUNDS}
    |"multi_pattern"
        {Parser.MULTI_PATTERN}
    |"transpose"
        {Parser.TRANSPOSE}
    |"mirror"
        {Parser.MIRROR}
    |"concatenate"
        {Parser.CONCATENATE}
    |"repeat"
        {Parser.REPEAT}
    |"transform"
        {Parser.TRANSFORM}
    |"partial_compose"
        {Parser.PARTIAL_COMPOSE}
    |"full_compose"
        {Parser.FULL_COMPOSE}
    |"binarily_compose"
        {Parser.BINARILY_COMPOSE}
    |"colorize"
        {Parser.COLORIZE}
    |"generate"
        {Parser.GENERATE}
    |"partial"
        {Parser.PARTIAL}
    |"full"
        {Parser.FULL}
    |"colored"
        {Parser.COLORED}
    |"temporize"
        {Parser.TEMPORIZE}
    |"rhythmize"
        {Parser.RHYTHMIZE}
    |"harmonize"
        {Parser.HARMONIZE}
    |"arpeggiate"
        {Parser.ARPEGGIATE}
    |"mobiusate"
        {Parser.MOBIUSATE}
    |integer
        {Parser.INTEGER (int_of_string (Lexing.lexeme lexbuf))}
    |name
        {Parser.NAME (Lexing.lexeme lexbuf)}
    |'{'
        {comment 0 lexbuf}
    |eof
        {Parser.EOF}
    |_ as c
        {Tools.unexpected_character_error c}

and comment level = parse
    |'\n'
        {Tools.next_line lexbuf; comment level lexbuf}
    |'}'
        {if level = 0 then read lexbuf else comment (level - 1) lexbuf}
    |'{'
        {comment (level + 1) lexbuf}
    |eof
        {Tools.unclosed_comment_error ()}
    |_
        {comment level lexbuf}

