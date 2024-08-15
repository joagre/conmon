-module(streamer).
-export([start/0, start/1]).

-include("smon.hrl").

-define(SPEED, (1024 * 1024 * 2)). % 2MB
-define(SLEEP_TIME, 500). % Sleep time in milliseconds

start() ->
    start(?PORT).

start(Port) ->
    {ok, ListenSocket} =
        gen_tcp:listen(Port, [binary, {packet, 0}, {active, false},
                              {reuseaddr, true}]),
    io:format("Listening on port ~p~n", [Port]),
    accept(ListenSocket).

accept(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    ok = inet:setopts(Socket, [{nodelay, true}, {sndbuf, 128 * 1024}]),
    {ok, [{sndbuf, Sndbuf}]} = inet:getopts(Socket, [sndbuf]),
    io:format("sndbuf: ~w\n", [Sndbuf]),
    io:format("Client connected~n"),
    Data = crypto:strong_rand_bytes(?CHUNK_SIZE),
    spawn(fun() -> stream_data(Socket, Data) end),
    accept(ListenSocket).

stream_data(Socket, Data) ->
    case check_for_timestamp(Socket) of
        ok ->
            ok = gen_tcp:send(Socket, <<?DATA_HEADER:8, Data/binary>>),
            timer:sleep(?SLEEP_TIME),
            stream_data(Socket, Data);
        {error, closed} ->
            io:format("Client disconnected~n"),
            ok;
        {error, Reason} ->
            io:format("Stream error: ~p~n", [Reason]),
            {error, Reason}
    end.

check_for_timestamp(Socket) ->
    case gen_tcp:recv(Socket, ?TIMESTAMP_SIZE, 0) of
        {ok, <<Timestamp:?TIMESTAMP_SIZE/binary>>} ->
            gen_tcp:send(Socket, <<?TIMESTAMP_HEADER:8, Timestamp/binary>>);
        {error, timeout} ->
            ok;
        {error, Reason} ->
            {error, Reason}
    end.
