CC=gcc

rcon: src/rcon.c
	mkdir -p bin
	gcc -o bin/rcon src/rcon.c
