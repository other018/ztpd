--------------------------------------------------------------------------------
---------------------------------- Oracle Text ---------------------------------
--------------------------------------------------------------------------------

------------------------------------
--- Operator CONTAINS - Podstawy ---
------------------------------------

--1.
CREATE TABLE my_cytaty AS SELECT * FROM ZSBD_TOOLS.CYTATY;

--2.
SELECT * FROM my_cytaty WHERE LOWER(tekst) LIKE '%optymista%' AND LOWER(tekst) LIKE '%pesymista%';

--3.
create index my_cytaty_idx on my_cytaty(tekst) indextype is CTXSYS.CONTEXT;

--4.
select * from my_cytaty mc where CONTAINS(mc.tekst,'optymista AND pesymista')>0;

--5.
select * from my_cytaty mc where CONTAINS(mc.tekst,'pesymista not optymista')>0;

--6.
select * from my_cytaty mc where CONTAINS(mc.tekst,'near((optymista, pesymista), 3)')>0;

--7.
select * from my_cytaty mc where CONTAINS(mc.tekst,'near((optymista, pesymista), 10)')>0;

--8.
select * from my_cytaty mc where CONTAINS(mc.tekst,'¿yci%')>0;

--9.
select score(1), autor, tekst from my_cytaty mc where CONTAINS(mc.tekst,'¿yci%',1)>0;

--10.
SELECT * FROM (
    select score(1), autor, tekst from my_cytaty mc where CONTAINS(mc.tekst,'¿yci%',1)>0 ORDER BY SCORE(1) DESC
) result WHERE rownum = 1;

--11.
select score(1), autor, tekst from my_cytaty mc where CONTAINS(mc.tekst,'fuzzy(probelm)',1)>0;

--12.
insert into my_cytaty values (100, 'Bertrand Russell', 'To smutne, ¿e g³upcy s¹ tacy pewni siebie, a ludzie rozs¹dni tacy pe³ni w¹tpliwoœci.');
commit;

--13.
select * from my_cytaty mc where CONTAINS(mc.tekst,'g³upcy')>0;
--Brak indexu na nowej wartoœci

--14.
SELECT * FROM DR$my_cytaty_idx$I;
-- Wyraz g³upcy nie znajduje siê w powy¿szej tabeli

--15.
DROP INDEX my_cytaty_idx;
create index my_cytaty_idx on my_cytaty(tekst) indextype is CTXSYS.CONTEXT;

--16.
SELECT * FROM DR$my_cytaty_idx$I;
-- Teraz wyraz g³upcy jest umieszczony w indeksie
select * from my_cytaty mc where CONTAINS(mc.tekst,'g³upcy')>0;

--17.
DROP INDEX my_cytaty_idx;
DROP TABLE my_cytaty;

------------------------------------------------
--- Zaawansowane indeksowanie i wyszukiwanie ---
------------------------------------------------
--1.
CREATE TABLE my_quotes AS SELECT * FROM ZSBD_TOOLS.QUOTES;

--2.
create index my_quotes_idx on my_quotes(text) indextype is CTXSYS.CONTEXT;

--3.
select * from my_quotes mq where CONTAINS(mq.text,'work')>0; --176, 204
select * from my_quotes mq where CONTAINS(mq.text,'$work')>0; --165, 176, 204
select * from my_quotes mq where CONTAINS(mq.text,'working')>0; --165
select * from my_quotes mq where CONTAINS(mq.text,'$working')>0; --165, 176, 204

--4.
select * from my_quotes mq where CONTAINS(mq.text,'it')>0;
-- Nic nie zwrocil, 'it' jest stop-word'em

--5.
SELECT * FROM CTX_STOPLISTS;
-- Wykorzystywana byla domyœlna - DEFAULT_STOPLIST

--6.
SELECT * FROM CTX_STOPWORDS WHERE spw_stoplist = 'DEFAULT_STOPLIST';

--7.
DROP INDEX my_quotes_idx;
create index my_quotes_idx on my_quotes(text) indextype is CTXSYS.CONTEXT
    parameters('stoplist CTXSYS.EMPTY_STOPLIST');

--8.
select * from my_quotes mq where CONTAINS(mq.text,'it')>0;
-- Tak, zwróci³ 12 wyników

--9.
select * from my_quotes mq where CONTAINS(mq.text,'fool AND humans')>0;

--10.
select * from my_quotes mq where CONTAINS(mq.text,'fool AND computer')>0;

--11.
select * from my_quotes mq where CONTAINS(mq.text,'(fool AND humans) within SENTENCE')>0;
-- sekcja SENTENCE nie istnieje -> nie utworzyliœmy sekcji wykorzystywanej w zapytaniu

--12.
DROP INDEX my_quotes_idx;

--13.
begin
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup',  'SENTENCE');
    ctx_ddl.add_special_section('nullgroup',  'PARAGRAPH');
end;
/

--14.
create index my_quotes_idx on my_quotes(text) indextype is CTXSYS.CONTEXT parameters ('section group nullgroup');

--15.
select * from my_quotes mq where CONTAINS(mq.text,'(fool AND humans) within SENTENCE')>0;
select * from my_quotes mq where CONTAINS(mq.text,'(fool AND computer) within SENTENCE')>0;

--16.
select * from my_quotes mq where CONTAINS(mq.text,'humans')>0;
-- Zwróci³ non-humans, ze wzgledu na myœlnik tokenem jest tylko humans - non-humans uzna³ za odmianê wyrazu

--17.
DROP INDEX my_quotes_idx;

begin
    ctx_ddl.create_preference('lexer_myslnik','BASIC_LEXER');
    ctx_ddl.set_attribute('lexer_myslnik', 'printjoins', '-');
end;
/

create index my_quotes_idx on my_quotes(text) indextype is CTXSYS.CONTEXT parameters ('LEXER lexer_myslnik');

--18.
select * from my_quotes mq where CONTAINS(mq.text,'humans')>0;
-- Tym razem nie zwróci³

--19.
select * from my_quotes mq where CONTAINS(mq.text,'non\-humans')>0;

--20.
begin
    ctx_ddl.drop_section_group('nullgroup');
    ctx_ddl.drop_preference('lexer_myslnik');
end;
/

drop table my_quotes;