-module(login).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/login.html" }.

title() ->
    "SuperShop: Login page".

login() ->
    Login = case wf:user() of
        undefined ->
            "You are not logged in.";
        X ->
            wf:f("Welcome ~s. ",[X])
    end,
    [
     #p{ body =[Login,
                #link { show_if=( wf:user()/= undefined ),
                        text="Log out", postback=logout}]},
     #p{},
     #label { text="login" },
     #textbox { id=tb_login, text="" , next=tb_passowrd},
     #p{},
     #label { text="password" },
     #password {id=tb_password, text="" },
     #p{},
     #button { text="Login",
               actions=#event{type=click,postback=login}},

     #button { text="test",
               actions=#event{type=click,postback=test}}
     ].

event(login) ->
    case db_login:validate(wf:q("tb_login"),wf:q("tb_password")) of
        {ok,User} ->
            wf:user(User),
            wf:redirect_from_login("login");
        {error,X} ->
            error_logger:error_report("module: login, error: "++X),
            wf:redirect_from_login("login")
    end;
event(logout) ->
    wf:clear_session(),
    wf:redirect("login");
event(test) ->
    db_login:test(),
    X = db_login:add_account("asd","qwe","email3"),
    io:format("~p~n",[X]);
    %db_login:upload_image();
event(_) ->
    ok.
