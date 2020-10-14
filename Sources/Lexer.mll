(* Author: Samuele Giraudo
 * Creation: oct. 2020
 * Modifications: oct. 2020
 *)

let letter = ['a'-'z' 'A'-'Z' '_']
let digits = ['0'-'9']
let plain_character = letter | digits

let name = letter plain_character*
let integer = '-'? digits+
let pos_float = integer '.' digits+

rule read = parse
    |' ' |'\t'
        {read lexbuf}
    |'\n'
        {Tools.next_line lexbuf; read lexbuf}
    |'('
        {Parser.PAR_L}
    |')'
        {Parser.PAR_R}
    |'.'
        {Parser.POINT}
    |':'
        {Parser.COLON}
    |'<'
        {Parser.LT}
    |'>'
        {Parser.GT}
    |'*'
        {Parser.STAR}
    |'#'
        {Parser.SHARP}
    |'@' integer
        {Parser.AT_INTEGER (int_of_string (ExtLib.String.lchop (Lexing.lexeme lexbuf)))}
    |'@' name
        {Parser.AT_LABEL (ExtLib.String.lchop (Lexing.lexeme lexbuf))}
    |"@@"
        {Parser.AT_AT}
    |'='
        {Parser.EQUALS}
    |'\''
        {Parser.PRIME}
    |','
        {Parser.COMMA}
    |"begin"
        {Parser.BEGIN}
    |"end"
        {Parser.END}
    |"repeat"
        {Parser.REPEAT}
    |"reverse"
        {Parser.REVERSE}
    |"complement"
        {Parser.COMPLEMENT}
    |"let"
        {Parser.LET}
    |"put"
        {Parser.PUT}
    |"in"
        {Parser.IN}
    |"layout"
        {Parser.LAYOUT}
    |"root"
        {Parser.ROOT}
    |"time"
        {Parser.TIME}
    |"duration"
        {Parser.DURATION}
    |"synthesizer"
        {Parser.SYNTHESIZER}
    |"effect"
        {Parser.EFFECT}
    |"scale"
        {Parser.SCALE}
    |"delay"
        {Parser.DELAY}
    |"clip"
        {Parser.CLIP}
    |"tremolo"
        {Parser.TREMOLO}
    |integer
        {Parser.INTEGER (int_of_string (Lexing.lexeme lexbuf))}
    |pos_float
        {Parser.POS_FLOAT (float_of_string (Lexing.lexeme lexbuf))}
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

