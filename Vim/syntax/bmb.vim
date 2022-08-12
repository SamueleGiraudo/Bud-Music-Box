" Author: Samuele Giraudo
" Creation: aug. 2022
" Modifications: aug. 2022

" Syntax file of the Bud Music Box language.
" This file has to be at ~/.vim/syntax/bmb.vim

if exists("b:current_syntax")
    finish
endif

" Turns off spell checking.
set nospell

" To allow '-' to be part of a keyword.
setlocal iskeyword+=-

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
syn keyword Structure repeat
syn keyword Structure stack
syn keyword Structure partial-compose
syn keyword Structure full-compose
syn keyword Structure colorize
syn keyword Structure mono-colorize
syn keyword Structure generate

" Options of commands.
syn keyword Special add-int
syn keyword Special cyclic
syn keyword Special max
syn keyword Special partial
syn keyword Special full
syn keyword Special homogeneous

" Stacking patterns.
syn match Conditional "+"

" For the parts of colored multi-patterns.
syn match Function "|"

" Rests.
syn match Macro "."

" Match colors.
syn match Constant "%[a-zA-Z]\+[a-zA-Z0-9_]*"

" Multi-pattern or colored multi-pattern names.
syn match Normal "[a-zA-Z]\+[a-zA-Z0-9_]*"

" Numbers.
syn match Number "\d\+"

" Comments.
syn region Comment start="{" end="}"

