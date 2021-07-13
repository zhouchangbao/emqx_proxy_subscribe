%%--------------------------------------------------------------------
%% Copyright (c) 2020 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_proxy_subscribe_SUITE).

-compile(export_all).

all() -> [test_request].

groups() -> [].


test_request(_) ->
  Config = [{http_url, "http://106.14.180.120:15092/iot/auth/listSubscribeTopic"}],
  Topics = emqx_proxy_subscribe_cli:topicList(Config,
    <<"ed393046309e435a80c08dfd45ae5c5d.100007358|timestamp=2524608000000,_v=sdk-c-3.0.1,securemode=3,signmethod=hmacsha256,lan=C,gw=0,ext=0|">>,
    <<"100007358.ed393046309e435a80c08dfd45ae5c5d">>),

  TopicList = lists:map(fun(X) ->
    Qos = maps:get(<<"qos">>, X),
    Topic = maps:get(<<"topic">>, X),
    {Topic, #{qos => Qos}} end, Topics),
  ct:log("res ~n~p~n", [TopicList]).
