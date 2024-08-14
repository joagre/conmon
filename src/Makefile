ERLC=erlc
SRC=$(wildcard *.erl)
BEAMS=$(SRC:%.erl=../ebin/%.beam)

all: $(BEAMS)

../ebin/%.beam: %.erl
	$(ERLC) -o ../ebin $<

clean:
	rm -f ../ebin/*.beam

.PHONY: all clean
