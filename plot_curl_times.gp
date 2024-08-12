#!/usr/bin/env gnuplot

set terminal pngcairo size 800,600
set output 'curl_log.png'

set title "100MB download time"
set xlabel "Time (Unix timestamp)"
set ylabel "Download time (seconds)"
set grid

plot "/tmp/curl.log" using 1:2 with linespoints title "Download time"
