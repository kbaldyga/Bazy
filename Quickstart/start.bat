erl -name nitrogen@127.0.0.1 -pa ./ebin ../apps/*/ebin ../apps/*/include  -env ERL_FULLSWEEP_AFTER 10 -eval "application:start(mnesia)"  -eval "application:start(mprocreg)" -eval "application:start(quickstart)"