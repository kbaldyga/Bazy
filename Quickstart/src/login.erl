-module(login).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/login.html" }.

title() ->
    "SuperShop: Login page".

inout() ->
    Login = case wf:login() of
                undefined ->
                    #label { text="<a href=login>Login</a>"};
                _X ->
                    #label { text="<a href=login>Logged as "++_X++"</a>" }
            end,
    Login.

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
     #p {},
     "</br></br>",
     #label { text="Need new account?" },
     #link { text="Sign up!", url=add_account }
     ].

event(login) ->
    case db_login:validate(wf:q("tb_login"),wf:q("tb_password")) of
        {ok,User} ->
            wf:user(User),
            wf:session(uid,db_login:get_id(User)),
            wf:redirect_from_login("category");
        {error,X} ->
            %error_logger:error_report("module: login, error: "++X),
            wf:redirect_to_login("login")
    end;
event(logout) ->
    wf:clear_session(),
    wf:redirect("login");
event(_) ->
    ok.
