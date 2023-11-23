# Author: Samuele Giraudo
# Creation: jul. 2022
# Modifications: jul. 2022, nov. 2023

CC = ocamlbuild
FLAGS = -r -cflags -w,A-4-70 -menhir "menhir --explain"
LIBS =-package unix -use-menhir

SRC_DIR = Sources

NAME = bmb
EXEC = BudMusicBox.native

.PHONY: all
all: $(NAME)

.PHONY: $(NAME)
$(NAME):
	$(CC) $(FLAGS) $(LIBS) $(SRC_DIR)/$(EXEC)
	mv -f $(EXEC) $(NAME)

.PHONY: noassert
noassert: FLAGS += -cflag -noassert
noassert: all

.PHONY: clean
clean:
	rm -rf _build
	rm -f $(NAME)

.PHONY: stats
stats:
	wc $(SRC_DIR)/*.ml $(SRC_DIR)/*.mly $(SRC_DIR)/*.mll

