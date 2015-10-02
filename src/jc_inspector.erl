-module(jc_inspector).

%% API
-export([dump/3]).

%% NIFs
-export([inspect/0,
         word/1]).

-on_load(init/0).
-define(nif_stub, nif_stub_error(?LINE)).
nif_stub_error(Line) ->
    erlang:nif_error({nif_not_loaded,module,?MODULE,line,Line}).

init() ->
    PrivDir = case code:priv_dir(?MODULE) of
                  {error, bad_name} ->
                      EbinDir = filename:dirname(code:which(?MODULE)),
                      AppPath = filename:dirname(EbinDir),
                      filename:join(AppPath, "priv");
                  Path ->
                      Path
              end,
    erlang:load_nif(filename:join(PrivDir, ?MODULE), 0).


dump(File, From, To) ->
    {ok, Handle} = file:open(File, [write]),
    Step = erlang:system_info(wordsize),
    do_dump(Handle, From, To, Step).

do_dump(Handle, From, To, _) when From > To ->
    ok = file:close(Handle);
do_dump(Handle, From, To, Step) ->
    Word = word(From),
    IoList = [integer_to_binary(From, 16), <<":">>,
              integer_to_binary(Word, 16), <<"\n">>],
    ok = file:write(Handle, IoList),
    do_dump(Handle, From+Step, To, Step).

inspect() ->
    ?nif_stub.

word(_Addr) ->
    ?nif_stub.
