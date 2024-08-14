ERL=erl

all:
	(cd src; make all)

start:
	$(ERL) -pa ebin

clean:
	rm -f erl_crash.dump timestamp_log.txt
	(cd src; make clean)

.PHONY: all clean
