-module(client).
-export([start/0, start/1, start/2]).

-include("smon.hrl").

-define(TIMESTAMP_INTERVAL, 2000).
-define(LOG_FILE, "timestamp_log.txt").

start() ->
    start({127, 0, 0, 1}, ?PORT).

start(Host) ->
    start(Host, ?PORT).

start(Host, Port) ->
    {ok, Socket} =
        gen_tcp:connect(Host, Port, [binary, {packet, 0}, {active, false}]),
    _ = file:delete(?LOG_FILE),
    io:format("Connected to server ~p:~p~n", [Host, Port]),
    spawn(fun() -> send_timestamps(Socket) end),
    receive_data(Socket).

send_timestamps(Socket) ->
    Timestamp = erlang:monotonic_time(millisecond),
    ok = gen_tcp:send(Socket, <<Timestamp:(?TIMESTAMP_SIZE * 8)/signed-big>>),
    RandomSleep = ?TIMESTAMP_INTERVAL + rand:uniform(?TIMESTAMP_INTERVAL),
    ok = timer:sleep(RandomSleep),
    send_timestamps(Socket).

receive_data(Socket) ->
    case gen_tcp:recv(Socket, 1) of
        {ok, <<?DATA_HEADER:8>>} ->
            case gen_tcp:recv(Socket, ?CHUNK_SIZE) of
                {ok, _} ->
                    receive_data(Socket);
                {error, Reason} ->
                    {error, Reason}
            end;
        {ok, <<?TIMESTAMP_HEADER:8>>} ->
            case gen_tcp:recv(Socket, ?TIMESTAMP_SIZE) of
                {ok, <<EchoedTimestamp:(?TIMESTAMP_SIZE * 8)/signed-big>>} ->
                    EndTimestamp = erlang:monotonic_time(millisecond),
                    ok = measure_and_log_round_trip(EchoedTimestamp, EndTimestamp),
                    receive_data(Socket);
                {error, Reason} ->
                    {error, Reason}
            end;
        {error, Reason} ->
            {error, Reason}
    end.

measure_and_log_round_trip(StartTimestamp, EndTimestamp) ->
    RoundTripTime = EndTimestamp - StartTimestamp,
    LogEntry = io_lib:format("~w~n", [RoundTripTime]),
    ok = file:write_file(?LOG_FILE, LogEntry, [append]),
    io:format("Round-trip time: ~p ms, logged to file~n", [RoundTripTime]).
