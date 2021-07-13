-module(emqx_proxy_subscribe).

-include("emqx.hrl").
-include("emqx_mqtt.hrl").
-include_lib("logger.hrl").

-export([load/1
  , unload/0
]).

%% Client Lifecircle Hooks
-export([on_client_connected/3
]).

load(Env) ->
  emqx:hook('client.connected', {?MODULE, on_client_connected, [Env]}).

on_client_connected(#{clientid := ClientId, username := UserName}, ConnInfo, _Env) ->
  TopicList = emqx_proxy_subscribe_cli:topicList(_Env, ClientId, UserName),
  TopicFilters = lists:map(fun(X) ->
    Qos = maps:get(<<"qos">>, X),
    Topic = maps:get(<<"topic">>, X),
    {Topic, #{qos => Qos}} end, TopicList),
  ?LOG(info, "_ConnInfo to read ~p, ~p", [ClientId, TopicFilters]),
  self() ! {subscribe, TopicFilters}.


%% Called when the plugin application stop
unload() ->
  emqx:unhook('client.connected', {?MODULE, on_client_connected}).
