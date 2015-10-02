-module(jc_binary).

-export([inspect/1]).

inspect(Ptr0) ->
    WordSize = erlang:system_info(wordsize),
    {[Flags, Refc, Size], Ptr1} = read_words(Ptr0, WordSize, 3),
    Bytes = read_bytes(Ptr1, WordSize, Size),
    {Flags, Size, Refc, Bytes}.

read_bytes(Ptr, WordSize, N) ->
    read_bytes(Ptr, WordSize, N, <<>>).

read_bytes(_Ptr, _WordSize, N, Acc) when N =< 0 ->
    Size = byte_size(Acc) + N,
    {Head, _} = erlang:split_binary(Acc, Size),
    Head;
read_bytes(Ptr, WordSize, N, Acc) ->
    Word = jc_inspector:word(Ptr),
    Bytes = <<Word:WordSize/native-unit:8>>,
    read_bytes(Ptr+WordSize, WordSize, N-WordSize, <<Acc/binary, Bytes/binary>>).

read_words(Ptr, WordSize, N) ->
    read_words(Ptr, WordSize, N, []).

read_words(Ptr, _WordSize, 0, Acc) ->
    {lists:reverse(Acc), Ptr};
read_words(Ptr, WordSize, N, Acc) ->
    read_words(Ptr+WordSize, WordSize, N-1, [jc_inspector:word(Ptr)|Acc]).
