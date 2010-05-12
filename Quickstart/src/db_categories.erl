-module(db_categories).
-export([add_category/2,
         add_category/1,
         read_all/0]).

add_category(Name) ->
    add_category(Name,"").
add_category(Name,Description) ->
    Query = "insert into kategoria values (DEFAULT,'"++Name++"','"++Description++"');",
    database:sql_query(Query).

read_all() ->
    Query = "select nazwa, opis from kategoria",
    database:sql_query(Query).
