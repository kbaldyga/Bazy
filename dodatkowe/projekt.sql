drop table kategoria cascade;
drop table produkt cascade;
drop table zbior_kategorii cascade ;
drop table klient cascade;
drop table szczegoly cascade;
drop table dane_kontaktowe cascade ;
drop table zamowienie cascade ;
drop table zbior_zamowien cascade;

create table kategoria
(
       id_kategoria serial primary key not null,
       nazwa character varying (128) not null,
       opis text default ''
) ;

create table produkt
(
        id_produkt serial primary key not null,
        nazwa character varying (128) not null,
        krotki_opis text not null,
        cena integer not null check(cena > 0),
        ile_dostepnych integer not null check (ile_dostepnych>=0)
) ;

create table zbior_kategorii
(
        id_produkt integer references produkt,
        id_kategoria integer references kategoria
) ;

create table klient
(
        id_klient serial primary key not null,
        login character varying(128) not null unique,
        haslo character varying(128) not null,
        email text unique
) ;

create table dane_kontaktowe
(
        id_klient integer references klient not null,
        ulica character varying(128) not null,
        nr_domu integer not null,
        nr_mieszkania integer,
        kod_pocztowy character(6) not null,
        miasto character varying(128) not null,
        telefon character(9)
) ;

create table szczegoly
(
        id_produkt integer references produkt unique,
        dlugi_opis text,
        zdjecie text
) ;

create table zamowienie
(
        id_zamowienie serial primary key not null unique,
        id_klient integer references klient not null,
        data_zamowienia timestamp default now(),
        platnosc character varying(128),
        czy_obsluzono boolean not null default false
) ;

create table zbior_zamowien
(
        id_produkt integer references produkt,
        id_zamowienie integer references zamowienie
) ;
----------------------------------------------------------------------------------
-- PERSPEKTYWY
----------------------------------------------------------------------------------
-- wyci±ganie wszystkich informacji z produktu
drop view produkt_into ;
create view produkt_info as (select distinct produkt.id_produkt as id_produkt, produkt.nazwa as nazwa, produkt.krotki_opis, szczegoly.dlugi_opis, produkt.cena, produkt.ile_dostepnych, szczegoly.zdjecie from produkt left join szczegoly on szczegoly.id_produkt = produkt.id_produkt );
-- select * from produkt_info where id_produkt = 10 ;
----------------------------------------------------------------------------------
drop view kategoria_info ;
-- wyciaganie nazwy kategorii, oraz liczby produktow w danej kategorii
create view kategoria_info as (select kategoria.nazwa as nazwa,zbior_kategorii.id_kategoria,count(*) from zbior_kategorii join kategoria on kategoria.id_kategoria=zbior_kategorii.id_kategoria group by zbior_kategorii.id_kategoria, kategoria.nazwa);
-- select * from kategoria_info
----------------------------------------------------------------------------------
drop view produkty_w_kategorii ;
create view produkty_w_kategorii as (select distinct produkt.id_produkt, produkt.nazwa as nazwa, produkt.krotki_opis, produkt.cena, produkt.ile_dostepnych, szczegoly.zdjecie, zbior_kategorii.id_kategoria as id_kategoria from produkt join zbior_kategorii on produkt.id_produkt = zbior_kategorii.id_produkt left join szczegoly on szczegoly.id_produkt = produkt.id_produkt) ;
select * from produkty_w_kategorii where id_kategoria=26
----------------------------------------------------------------------------------
-- DOSTÊP
----------------------------------------------------------------------------------
grant select on produkt_info to public ;
grant select on kategoria_info to public;
grant select on produkty_w_kategorii to public ;
grant insert on klient, dane_kontaktowe to anonim ;
grant select,update on klient_id_klient_seq to anonim ;
grant insert on zamowienie to klient ;
grant insert on zbior_zamowien to klient ;
grant select,update on klient, dane_kontaktowe to klient ;
grant select,insert on zamowienie,zbior_zamowien to klient ;
grant select,update on zamowienie_id_zamowienie_seq to klient ;
grant execute on function f_nowy_uzytkownik(text,text,text) to anonim ;
grant select,update on produkt to klient ;

----------------------------------------------------------------------------------
-- FUNKCJE
----------------------------------------------------------------------------------
drop function f_nowy_uzytkownik(text,text,text);
create function f_nowy_uzytkownik(nazwa text, haslo text, email text) returns setof klient as
$$
	declare
	begin
		insert into klient values(default,nazwa,(select md5(haslo)),email) ;
	end;
$$ language plpgsql ;
----------------------------------------------------------------------------------
-- nie pozwalamy dodac do zamowienia jesli jest 0 produktow na stanie
drop function f_zamow_produkt(integer,integer) cascade ;
create function f_zamow_produkt(pid integer, zid integer) returns text as
$$
	declare
		ile integer ;
	begin
		select into ile ile_dostepnych from produkt where id_produkt = $1 ;
		if not found then raise exception 'zamowienie nieistniejacego towaru' ; end if ;
		if ile = 0 then
			raise exception '0 produktow na stanie';
		end if ;
		update produkt set ile_dostepnych=ile-1 where id_produkt = $1 ;
		insert into zbior_zamowien values(pid,zid) ;
		return 'ok';
	end ;
$$ language plpgsql ;
----------------------------------------------------------------------------------
drop function f_sprawdz_login_haslo(text,text) ;
create function f_sprawdz_login_haslo(ilogin text,ihaslo text) returns boolean as
$$
	declare
	begin
		if (select haslo from klient where login = ilogin) = (select md5(ihaslo)) then
			return true ;
		end if;
		return false ;
	end ;
$$ language plpgsql ;