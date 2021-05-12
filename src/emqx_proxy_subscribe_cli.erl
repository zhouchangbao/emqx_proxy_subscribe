%%%-------------------------------------------------------------------
%%% @author bao
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 3月 2021 10:45 上午
%%%-------------------------------------------------------------------
-module(emqx_proxy_subscribe_cli).
-author("bao").

-import(proplists, [get_value/2, get_value/3]).

%% API
-export([topicList/3]).

topicList(Conf, ClientId, UserName) ->
  Url = get_value(http_url, Conf),
  RetryTimes = 5,
  Data = #{<<"clientId">> => ClientId, <<"userName">> => UserName},
  {ok, Body} = emqx_json:safe_encode(Data),
  case reply(post(Url, Body, RetryTimes)) of
    {ok, 200, Resp} ->
      {ok, Result} = emqx_json:safe_decode(iolist_to_binary(Resp), [return_maps]),
      maps:get(<<"data">>, Result);
    _ -> []
  end.

post(Url, Body, RetryTimes) ->
  Req = {Url, [{"Content-Type", "application/json"}], "application/json", Body},
  case httpc:request(post, Req, [{timeout, 5000}], []) of
    {error, _Reason} when RetryTimes > 0 ->
      timer:sleep(1000),
      io:format("reason ~n~p~n", [_Reason]),
      RetryTimes1 = RetryTimes -1,
      post(Url, Body, RetryTimes1);
    Other -> Other
  end.

reply({ok, {{_, Code, _}, _Headers, Body}}) ->
  {ok, Code, Body};
reply({ok, Code, Body}) ->
  {ok, Code, Body};
reply({error, Error}) ->
  {error, Error}.
