# Author: Samuele Giraudo
# Creation: jul. 2022
# Modifications: jul. 2022

CC = ocamlbuild
FLAGS = -r -cflags -w,A-4-70
LIBS = -libs str -libs unix -package extlib -use-menhir

NAME = bmb
EXEC = Main.native
SRC_DIR = Sources

.PHONY: all
all:
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

