FLAG = gcc -gstabs -m32 -no-pie

all: bin/postfix

bin/postfix: obj/postfix.o
	$(FLAG) obj/main.o obj/postfix.o -o bin/postfix

obj/postfix.o:
	$(FLAG) -c src/main.c -o obj/main.o
	$(FLAG) -c src/postfix.s -o obj/postfix.o

clean:
	rm -rf obj/postfix.o obj/main.o bin/postfix
