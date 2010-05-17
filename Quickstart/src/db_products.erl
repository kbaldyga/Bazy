-module(db_products).
-compile(export_all).

add_product(Name, SDesc, Price, Available) ->
    add_product(Name,SDesc,"", Price,Available,"").
add_product(Name,SDesc,LDesc, Price,Available, Photo) ->
    Query = wf:f(
              "insert into produkt values(DEFAULT,'~s','~s',~s,~s) RETURNING produkt_id",
              [Name,SDesc,Price,Available]),
    case database:sql_query(Query) of
        {error,_X} ->
            {error,_X} ;
        {selected,["produkt_id"],Id} ->
            NId = element(1,hd(Id)),
            Query2 = wf:f(
                      "insert into szczegoly values(~p,'~s','~s')",
                      [NId,LDesc,Photo]),
            database:sql_query(Query2)
    end.
