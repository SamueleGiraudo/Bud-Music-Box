" Author: Samuele Giraudo
" Creation: aug. 2022
" Modifications: aug. 2022, nov. 2023

" Syntax file of the Bud Music Box language.
" This file has to be at ~/.vim/syntax/bmb.vim

if exists("b:current_syntax")
    finish
endif

" Turns off spell checking.
set nospell

" To allow '-' to be part of a keyword.
setlocal iskeyword+=-

" Comments.
syn region Comment start="{" end="}" containedin=ALL

" Commands.
syn keyword Structure show
syn keyword Structure write
syn keyword Structure play
syn keyword Structure scale
syn keyword Structure root
syn keyword Structure tempo
syn keyword Structure sounds
syn keyword Structure monoid
syn keyword Structure multi-pattern
syn keyword Structure mirror
syn keyword Structure inverse
syn keyword Structure concatenate
syn keyword Structure concatenate-repeat
syn keyword Structure stack
syn keyword Structure stack-repeat
syn keyword Structure partial-compose
syn keyword Structure full-compose
syn keyword Structure colorize
syn keyword Structure mono-colorize
syn keyword Structure generate

" Options of commands.
syn keyword String add
syn keyword String cyclic
syn keyword String mul
syn keyword String mul-mod
syn keyword String max
syn keyword String partial
syn keyword String full
syn keyword String homogeneous

" Stacking patterns.
syn match Conditional "+"

" For the parts of colored multi-patterns.
syn match Function "|"

" Rests.
syn match Macro "."

" Match colors.
syn match Constant "%[a-zA-Z_']\+[a-zA-Z0-9_']*"

" Multi-pattern or colored multi-pattern names.
syn match Normal "[a-zA-Z_']\+[a-zA-Z0-9_']*"

" Numbers.
syn match Number "\d\+"

