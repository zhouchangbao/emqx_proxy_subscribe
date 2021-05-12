%%%-------------------------------------------------------------------
%%% @author bao
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 3月 2021 5:35 下午
%%%-------------------------------------------------------------------
-module(emqx_proxy_subscribe_cli_SUITE).
-author("bao").

-compile(export_all).
-compile(nowarn_export_all).

-include_lib("eunit/include/eunit.hrl").

all() -> [test_request].

test_request(_) ->
  emqx_proxy_subscribe_cli:request(""),
  ?assertEqual(true, false).
