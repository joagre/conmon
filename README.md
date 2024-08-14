# Network monitors

## Ping roundtrips and downloads

This monitor uses `ping` and `curl` to measure roundtrip and download
speed. It calls `ping` at random intervals and log roundtrip times in
`/tmp/ping.log`. It also calls `curl` to download a
http://speedtest.tele2.net/100MB.zip at random intervals and log
download times in `/tmp/curl.log`.

The commands `./plot_ping_times.gp` and `./plot_curl_times.gp` can be
used to visualize `/tmp/ping.log` and `/tmp/curl/log` as Gnuplot graphs:

Example:

```
$ ./conmon.sh
Next curl in 80 seconds
Next ping in 10 seconds
Next ping in 21 seconds
Next ping in 16 seconds
Next ping in 28 seconds
Next curl in 81 seconds
Next ping in 28 seconds
Next ping in 25 seconds
Next ping in 29 seconds
Next curl in 74 seconds
Next ping in 11 seconds
Next ping in 21 seconds
Next ping in 23 seconds
Next ping in 27 seconds
Next curl in 120 seconds
Next ping in 10 seconds
Next ping in 18 seconds
Next ping in 17 seconds
<ctrl-c>
$ ./plot_ping_times.gp
$ eog ping_log.png
$ ./plot_curl_times.gp
$ eog curl_log.png
```

![Ping times](examples/ping_log.png)

![Download times](examples/curl_log.png)

No more, no less.

## Delays in continuous streams of data

This monitor measures the delay in a continous 2MB/s data stream. A
timestamp is echoed within the stream at random intervals (~3 seconds)
and the roundtrip time is logged in `./timestamp_log.txt`.

Start a streamer server on host A and a streamer client on host B to
start a monitor session. In the example below both A and B is run on
the same host.

Example (streamer host A):

```
$ make
$ make start
erl -pa ebin
Erlang/OTP 26 [erts-14.0.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit:ns]

Eshell V14.0.2 (press Ctrl+G to abort, type help(). for help)
1> streamer:start().
Listening on port 12345
```

Example (client host B):

```
$ make
$ make start
erl -pa ebin
Erlang/OTP 26 [erts-14.0.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit:ns]

Eshell V14.0.2 (press Ctrl+G to abort, type help(). for help)
1> client:start("localhost").
Connected to server "localhost":12345
Round-trip time: 35 ms, logged to file
Round-trip time: 182 ms, logged to file
Round-trip time: 358 ms, logged to file
Round-trip time: 103 ms, logged to file
Round-trip time: 487 ms, logged to file
Round-trip time: 19 ms, logged to file
Round-trip time: 136 ms, logged to file
Round-trip time: 266 ms, logged to file

BREAK: (a)bort (A)bort with dump (c)ontinue (p)roc info (i)nfo
       (l)oaded (v)ersion (k)ill (D)b-tables (d)istribution
^C
$ cat timestamp_log.txt
35
182
358
103
487
19
136
266
```

No more, no less.
