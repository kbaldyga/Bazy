-module(db_categories).
-export([add_category/2,
         add_category/1,
         read_all/0]).
-compile(export_all).

add_category(Name) ->
    add_category(Name,"").
add_category(Name,Description) ->
    Query = "insert into kategoria values (DEFAULT,'"++Name++"','"++Description++"');",
    database:sql_query(Query).

category_name(Id) ->
    Query = wf:f("select nazwa from kategoria where id_kategoria=~p",[Id]),
    case database:sql_query(Query) of
        {error,_X} ->
            {error,_X} ;
        {selected,_C,Rows} ->
            element(1,hd(Rows))
   end.

read_all() ->
    Query = "select * from kategoria",
    database:sql_query(Query).
