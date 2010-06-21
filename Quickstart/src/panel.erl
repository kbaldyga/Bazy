-module(panel).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file="./templates/panel.html" }.

title() ->
    "SuperShop - panel klienta".

categories() ->
    category:categories().

panel() ->
    Body = case wf:user() of
             undefined ->
                  wf:redirect_to_login("login");
             N ->
                  wf:session(uid,db_login:get_id(N)),
                  content()
           end,
    Body.

content_data() ->
    db_panel:data().
content_map() ->
    [
     ulica@text,
     nr_domu@text,
     nr_mieszkania@text,
     kod_pocztowy@text,
     miasto@text,
     telefon@text
    ].

content() ->
    Data = content_data(),
    Map = content_map(),
    Body = [
       #table { class="sample", rows=[
            #tablerow { cells=[
              #tableheader { style="width:50px;",text="ulica" },
              #tableheader { style="width:50px;",text="nr domu" },
              #tableheader { style="width:50px;",text="nr mie" },
              #tableheader { style="width:50px;",text="kod pocz." },
              #tableheader { style="width:100px;",text="miasto" },
              #tableheader { style="width:50px;",text="telefon" }
              ]
                      },
            #bind { id=table, data=Data, map=Map,
                    %transform=fun transform/2,
                       body=#tablerow { id=top, cells=[
                       #tablecell { style="width:50px;",body=#textbox{id=ulica }},
                       #tablecell { style="width:50px;",body=#textbox{id=nr_domu}},
                       #tablecell { style="width:50px;",body=#textbox{id=nr_mieszkania} },
                       #tablecell { style="width:50px;",body=#textbox{id=kod_pocztowy} },
                       #tablecell { style="width:100px;",body=#textbox{id=miasto}},
                       #tablecell { style="width:50px;",body=#textbox{id=telefon }} ] } } ] }

           ],
    Body.
