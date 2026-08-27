main: obj/main.o
	ld -o main obj/main.o

obj/main.o: src/main.s obj/
	as -o obj/main.o src/main.s

obj:
	mkdir obj

run: main
	./main

clean:
	rm -rf obj main
