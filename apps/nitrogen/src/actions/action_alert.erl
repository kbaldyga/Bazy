% Nitrogen Web Framework for Erlang
% Copyright (c) 2008-2010 Rusty Klophaus
% See MIT-LICENSE for licensing information.

-module (action_alert).
-include_lib ("wf.hrl").
-compile(export_all).

render_action(Record) -> 
    wf:f("alert(\"~s\");", [wf:js_escape(Record#alert.text)]).	
