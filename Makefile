LEX = /usr/bin/flex
CFLAGS = -g
LDLIBS = -lfl
CC = /usr/bin/gcc
YACC = /usr/bin/yacc

compiler:
	clear
	rm -f ex lex.yy.c y.tab.c y.tab.h
	yacc -d fisier.y 
	lex  fisier.l
	gcc lex.yy.c  y.tab.c  -o ex
	./ex tests/test1.in

clean:
	rm -f ex lex.yy.c y.tab.c y.tab.h
