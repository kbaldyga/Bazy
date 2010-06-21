-module(user___).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file="./templates/zlecenia.html" }.

title() ->
    "SuperShop - informacje o kliencie".

klient_data() ->
    case wf:q("id") of
            undefined ->
                [] ;
            N -> db_user:info(N)
    end.
klient_map() ->
    [
     email@text,
     ulica@text,
     nr_domu@text,
     nr_mieszkania@text,
     kod_pocztowy@text,
     miasto@text,
     telefon@text
    ].

klient() ->
    Data = klient_data(),
    Map = klient_map(),
    Body =
      [
        #table { class="sample", rows=[
            #tablerow { cells=[
              #tableheader { style="width:100px;",text="email" },
              #tableheader { style="width:50px;",text="ulica" },
              #tableheader { style="width:15px;",text="nr domu" },
              #tableheader { style="width:15px;",text="nr mie" },
              #tableheader { style="width:30px;",text="kod pocztowy" },
              #tableheader { style="width:100px;",text="miasto" },
              #tableheader { style="width:50px;",text="telefon" }
              ]
                      },
            #bind { id=table, data=Data, map=Map,
                    %transform=fun transform/2,
                       body=#tablerow { id=top, cells=[
                       %#tablecell { style="width:17px;", id=id_zamowienie  },
                       #tablecell { style="width:100px;",id=email },
                       #tablecell { style="width:50px;",id=ulica },
                       #tablecell { style="width:15px;",id=nr_domu},
                       #tablecell { style="width:15px;",id=nr_mieszkania },
                       #tablecell { style="width:30px;",id=kod_pocztowy },
                       #tablecell { style="width:100px;",id=miasto},
                       #tablecell { style="width:50px;",id=telefon } ] } } ] }

           ],
    Body.
