ERL=erl

all:
	(cd src; make all)

start:
	$(ERL) -pa ../ebin -sname test

clean:
	(cd src; make clean)

.PHONY: all clean
