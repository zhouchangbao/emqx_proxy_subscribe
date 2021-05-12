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

-module(emqx_proxy_subscribe).

-include_lib("emqx/include/emqx.hrl").
-include_lib("emqx/include/emqx_mqtt.hrl").

-include_lib("emqx/include/logger.hrl").

-export([ load/1
  , unload/0
]).

%% Client Lifecircle Hooks
-export([on_client_connected/3]).




%% Called when the plugin application start
load(Env) ->
  emqx:hook('client.connected', {?MODULE, on_client_connected, [Env]}).

%%--------------------------------------------------------------------
%% Client Lifecircle Hooks
%%--------------------------------------------------------------------

on_client_connected(ClientInfo = #{clientid := ClientId, username := UserName}, ConnInfo, _Env) ->
  io:format("Client(~s) connected, ClientInfo:~n~p~n, ConnInfo:~n~p~n",
    [ClientId, ClientInfo, ConnInfo]),
  ?LOG(info, "ClientId:~p UserName:~p", [ClientId, UserName]),
  Result = emqx_proxy_subscribe_cli:topicList(_Env, ClientId, UserName),
  lists:foreach(fun(X) ->
    Qos = maps:get(<<"qos">>, X),
    Topic = maps:get(<<"topic">>, X),
    self() ! {subscribe, [{Topic, #{qos => Qos}}]} end,
    Result
  ).


%% Called when the plugin application stop
unload() ->
  emqx_hooks:del('client.connected', {?MODULE, on_client_connected}).

