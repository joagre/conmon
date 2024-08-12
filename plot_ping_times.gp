#!/usr/bin/env gnuplot

set terminal pngcairo size 800,600
set output 'ping_log.png'

set title "Roundtrip time"
set xlabel "Time (Unix timestamp)"
set ylabel "Roundtrip time (milliseconds)"
set grid

plot "/tmp/ping.log" using 1:2 with linespoints title "Roundtrip time"
