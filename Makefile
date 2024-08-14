ERL=erl

all:
	(cd src; make all)

start:
	$(ERL) -pa ebin

clean:
	(cd src; make clean)

.PHONY: all clean
