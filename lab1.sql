--------------------------------------------------------------------------------
---------------------------- Obiektowe bazy danych -----------------------------
--------------------------------------------------------------------------------

-----------------------------------
--- Tworzenie typow obiektowych ---
-----------------------------------

--1.
CREATE OR REPLACE TYPE SAMOCHOD AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2)
);

DESC samochod;

CREATE TABLE samochody OF samochod;

INSERT INTO samochody VALUES (NEW samochod('FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000));
INSERT INTO samochody VALUES (NEW samochod('FORD', 'MONDEO', 80000, '1997-05-10', 45000));
INSERT INTO samochody VALUES (NEW samochod('MAZDA', '323', 12000, '2000-09-22', 52000));

select * from samochody;

--2.
CREATE TABLE wlasciciele (
    IMIE VARCHAR2(100),
    NAZWISKO VARCHAR2(100),
    AUTO SAMOCHOD
);

DESC wlasciciele;

INSERT INTO wlasciciele VALUES ('JAN', 'KOWALSKI', NEW SAMOCHOD('FIAT', 'SEICENTO', 30000, '0010-12-02', 19500));
INSERT INTO wlasciciele VALUES ('ADAM', 'NOWAK', NEW SAMOCHOD('OPEL', 'ASTRA', 34000, '0009-06-01', 33700));

select * from wlasciciele;

--3.
ALTER TYPE samochod REPLACE AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2),
    MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        BEGIN
            RETURN ROUND(POWER(0.9, EXTRACT (YEAR FROM CURRENT_DATE)-EXTRACT (YEAR FROM DATA_PRODUKCJI) + KILOMETRY/10000) * CENA,2);
        END wartosc;
END;
/

SELECT s.marka, s.cena, s.wartosc() FROM SAMOCHODY s;

--4.
ALTER TYPE SAMOCHOD ADD MAP MEMBER FUNCTION odwzoruj
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        BEGIN
            RETURN ROUND(POWER(0.9,EXTRACT (YEAR FROM CURRENT_DATE)-EXTRACT (YEAR FROM DATA_PRODUKCJI) + KILOMETRY/10000) * CENA,2);
        END wartosc;

    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
        BEGIN
            RETURN EXTRACT (YEAR FROM CURRENT_DATE)-EXTRACT (YEAR FROM DATA_PRODUKCJI) + KILOMETRY/10000;
        END odwzoruj;
END;
/

SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);

--5.
CREATE OR REPLACE TYPE WLASCICIEL AS OBJECT (
    IMIE VARCHAR2(100),
    NAZWISKO VARCHAR2(100)
);

ALTER TYPE SAMOCHOD add attribute WLASCICIEL_ref REF WLASCICIEL CASCADE;

CREATE TABLE Twlasciciele of wlasciciel;

INSERT INTO TWLASCICIELE VALUES (NEW Wlasciciel('Anna','Kowalska'));
INSERT INTO TWLASCICIELE VALUES (NEW Wlasciciel('Jan','Kowalski'));

select * from samochody;

UPDATE samochody s
SET s.wlasciciel_ref = (
    SELECT REF(a) FROM twlasciciele a WHERE a.nazwisko='Kowalski'
);

select * from samochody;


------------------
---- KOLEKCJE ----
------------------

--6.
DECLARE
    TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.EXTEND(9);
    
    FOR i IN 2..10 LOOP
        moje_przedmioty(i) := 'PRZEDMIOT_' || i;
    END LOOP;
    
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;
    
    moje_przedmioty.TRIM(2);
    
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    
    moje_przedmioty.EXTEND();
    moje_przedmioty(9) := 9;
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    
    moje_przedmioty.DELETE();
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;
/

--7.
DECLARE
    TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
    ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    ksiazki(1) := 'ksiazka 1';
    
    DBMS_OUTPUT.PUT_LINE('Limit (1): ' || ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow (1): ' || ksiazki.COUNT());

    ksiazki.EXTEND(2);

    DBMS_OUTPUT.PUT_LINE('Limit (2): ' || ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow (2): ' || ksiazki.COUNT());

    FOR i IN ksiazki.FIRST()..ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(ksiazki(i));
    END LOOP;
    
    ksiazki(2) := 'Ksiazka 2';

    DBMS_OUTPUT.PUT_LINE('Limit (3): ' || ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow (3): ' || ksiazki.COUNT());

    ksiazki(3) := 'Ksiazka 3';

    FOR i IN ksiazki.FIRST()..ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(ksiazki(i));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Limit (4): ' || ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow (4): ' || ksiazki.COUNT());

    FOR i IN ksiazki.FIRST()..ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(ksiazki(i));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Limit (5): ' || ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow (5): ' || ksiazki.COUNT());

    ksiazki.TRIM(1);

    DBMS_OUTPUT.PUT_LINE('Limit (6): ' || ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow (6): ' || ksiazki.COUNT());

    FOR i IN ksiazki.FIRST()..ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(ksiazki(i));
    END LOOP;

    ksiazki.DELETE();
    
    DBMS_OUTPUT.PUT_LINE('Limit (7): ' || ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow (7): ' || ksiazki.COUNT());

    FOR i IN ksiazki.FIRST()..ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(ksiazki(i));
    END LOOP;

END;
/

--8.
DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.EXTEND(2);
    
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    
    moi_wykladowcy.EXTEND(8);
    
    FOR i IN 3..10 LOOP
        moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
    END LOOP;
    
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
    END LOOP;
    
    moi_wykladowcy.TRIM(2);
    
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
    END LOOP;
    
    moi_wykladowcy.DELETE(5,7);
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
    
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;
    
    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;
/

--9.
DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);
    miesiace t_miesiace := t_miesiace();
BEGIN
    miesiace.EXTEND(12);
    
    miesiace(1) := 'STYCZEN';
    miesiace(2) := 'LUTY';
    miesiace(3) := 'MARZEC';
    miesiace(4) := 'KWIECIEN';
    miesiace(5) := 'MAJ';
    miesiace(6) := 'CZERWIEC';
    miesiace(7) := 'LIPIEC';
    miesiace(8) := 'SIERPIEN';
    miesiace(9) := 'WRZESIEN';
    miesiace(10) := 'PAZDZIERNIK';
    miesiace(11) := 'LISTOPAD';
    miesiace(12) := 'GRUDZIEN';

    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END LOOP;
    
    miesiace.TRIM(2);
    
    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END LOOP;
    
    miesiace.DELETE(1);
    miesiace.DELETE(5);
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || miesiace.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || miesiace.COUNT());
    
    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE('Miesiac ' || i);

        IF miesiace.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(miesiace(i));
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || miesiace.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || miesiace.COUNT());
END;
/

--10.
--drop table semestry; drop type semestr; drop type lista_egzaminow; drop table stypendia; drop type stypendium; drop type jezyki_obce;

CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/

CREATE TYPE stypendium AS OBJECT (
    nazwa VARCHAR2(50),
    kraj  VARCHAR2(30),
    jezyki jezyki_obce
);
/

CREATE TABLE stypendia OF stypendium;

INSERT INTO stypendia VALUES
('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));

SELECT * FROM stypendia;

SELECT s.jezyki FROM stypendia s;

UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';

CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/

CREATE TYPE semestr AS OBJECT (
    numer NUMBER,
    egzaminy lista_egzaminow
);
/

CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;

INSERT INTO semestry VALUES
(semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
(semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));

SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;

SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;

SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );

INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');

UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';

DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';

--11.
CREATE TYPE koszyk_produktow AS TABLE OF VARCHAR2(20);
/

CREATE TYPE zakup AS OBJECT (
    klient VARCHAR(50),
    koszyk koszyk_produktow
);
/

CREATE TABLE zakupy OF zakup
    NESTED TABLE koszyk STORE AS tab_koszyki;

INSERT INTO zakupy VALUES
    (zakup('Kowalski',koszyk_produktow('jablko','banan','bulka')));
INSERT INTO zakupy VALUES
    (zakup('Nowak',koszyk_produktow('chleb','banan')));
INSERT INTO zakupy VALUES
    (zakup('Nowak2',koszyk_produktow('chleb','banany')));

SELECT * from zakupy;

delete from zakupy where 'banan' member of koszyk;
select * from zakupy;

---------------------------------------------------------
--- Polimorfizm, dziedziczenie, perspektywy obiektowe ---
---------------------------------------------------------

--12.
CREATE TYPE instrument AS OBJECT (
    nazwa VARCHAR2(20),
    dzwiek VARCHAR2(20),
    MEMBER FUNCTION graj RETURN VARCHAR2
) NOT FINAL;
/

CREATE TYPE BODY instrument AS
    MEMBER FUNCTION graj RETURN VARCHAR2 IS
        BEGIN
            RETURN dzwiek;
        END;
END;
/

CREATE TYPE instrument_dety UNDER instrument (
    material VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY instrument_dety AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
        BEGIN
            RETURN 'dmucham: '||dzwiek;
        END;
    
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
        BEGIN
            RETURN glosnosc||':'||dzwiek;
        END;
END;
/

CREATE TYPE instrument_klawiszowy UNDER instrument (
    producent VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
        BEGIN
            RETURN 'stukam w klawisze: '||dzwiek;
        END;
END;
/

DECLARE
    tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
    trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
    fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','pingping','steinway');
BEGIN
    dbms_output.put_line(tamburyn.graj);
    dbms_output.put_line(trabka.graj);
    dbms_output.put_line(trabka.graj('glosno'));
    dbms_output.put_line(fortepian.graj);
END;

--13.
CREATE TYPE istota AS OBJECT (
    nazwa VARCHAR2(20),
    NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
) NOT INSTANTIABLE NOT FINAL;
/

CREATE TYPE lew UNDER istota (
    liczba_nog NUMBER,
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
);
/

CREATE OR REPLACE TYPE BODY lew AS
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
        BEGIN
            RETURN 'upolowana ofiara: '||ofiara;
        END;
END;
/

DECLARE
    KrolLew lew := lew('LEW',4);
    InnaIstota istota := istota('JAKIES ZWIERZE'); -- proba utworzenia instancji typu, ktory jest NOT INSTANTIABLE
BEGIN
    DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;
/

--14.
DECLARE
    tamburyn instrument;
    cymbalki instrument;
    trabka instrument_dety;
    saksofon instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn','brzdek-brzdek');
    cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
    trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
    -- saksofon := instrument('saksofon','tra-taaaa'); --wyrazenie jest niewlasciwego typu
    -- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety); --blad liczby lub wartosci: nie mozna przypisac instancji supertypu do podtypu
END;
/

--15.
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa') );
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );

SELECT i.nazwa, i.graj() FROM instrumenty i;

--16.
CREATE TABLE PRZEDMIOTY (
    NAZWA VARCHAR2(50),
    NAUCZYCIEL NUMBER REFERENCES PRACOWNICY(ID_PRAC)
);

INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',100);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',100);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',110);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',110);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',120);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',120);
INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',130);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',140);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',140);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',140);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',150);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',150);
INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',160);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',160);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',170);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',180);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',180);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',190);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',200);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',210);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',220);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',220);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',230);

--17.
CREATE TYPE ZESPOL AS OBJECT (
    ID_ZESP NUMBER,
    NAZWA VARCHAR2(50),
    ADRES VARCHAR2(100)
);
/

--18.
CREATE OR REPLACE VIEW ZESPOLY_V OF ZESPOL
    WITH OBJECT IDENTIFIER(ID_ZESP)
    AS SELECT ID_ZESP, NAZWA, ADRES FROM ZESPOLY;

--19.
CREATE TYPE PRZEDMIOTY_TAB AS TABLE OF VARCHAR2(100);
/

CREATE TYPE PRACOWNIK AS OBJECT (
    ID_PRAC NUMBER,
    NAZWISKO VARCHAR2(30),
    ETAT VARCHAR2(20),
    ZATRUDNIONY DATE,
    PLACA_POD NUMBER(10,2),
    MIEJSCE_PRACY REF ZESPOL,
    PRZEDMIOTY PRZEDMIOTY_TAB,
    MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY PRACOWNIK AS
    MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER IS
        BEGIN
            RETURN PRZEDMIOTY.COUNT();
        END ILE_PRZEDMIOTOW;
END;
/

--20.
CREATE OR REPLACE VIEW PRACOWNICY_V OF PRACOWNIK
    WITH OBJECT IDENTIFIER (ID_PRAC) AS
        SELECT ID_PRAC, NAZWISKO, ETAT, ZATRUDNIONY, PLACA_POD, MAKE_REF(ZESPOLY_V,ID_ZESP),
        CAST(MULTISET( SELECT NAZWA FROM PRZEDMIOTY WHERE NAUCZYCIEL=P.ID_PRAC ) AS PRZEDMIOTY_TAB )
        FROM PRACOWNICY P;

--21.
SELECT *
FROM PRACOWNICY_V;

SELECT P.NAZWISKO, P.ETAT, P.MIEJSCE_PRACY.NAZWA
FROM PRACOWNICY_V P;

SELECT P.NAZWISKO, P.ILE_PRZEDMIOTOW()
FROM PRACOWNICY_V P;

SELECT * FROM TABLE( SELECT PRZEDMIOTY FROM PRACOWNICY_V WHERE NAZWISKO='WEGLARZ' );

SELECT NAZWISKO, CURSOR( SELECT PRZEDMIOTY
    FROM PRACOWNICY_V
    WHERE ID_PRAC=P.ID_PRAC
)
FROM PRACOWNICY_V P;

--22.
CREATE TABLE PISARZE (
    ID_PISARZA NUMBER PRIMARY KEY,
    NAZWISKO VARCHAR2(20),
    DATA_UR DATE
);

CREATE TABLE KSIAZKI (
    ID_KSIAZKI NUMBER PRIMARY KEY,
    ID_PISARZA NUMBER NOT NULL REFERENCES PISARZE,
    TYTUL VARCHAR2(50),
    DATA_WYDANIA DATE
);

INSERT INTO PISARZE VALUES(10,'SIENKIEWICZ',DATE '1880-01-01');
INSERT INTO PISARZE VALUES(20,'PRUS',DATE '1890-04-12');
INSERT INTO PISARZE VALUES(30,'ZEROMSKI',DATE '1899-09-11');

INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(10,10,'OGNIEM I MIECZEM',DATE '1990-01-05');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(20,10,'POTOP',DATE '1975-12-09');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(30,10,'PAN WOLODYJOWSKI',DATE '1987-02-15');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(40,20,'FARAON',DATE '1948-01-21');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(50,20,'LALKA',DATE '1994-08-01');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(60,30,'PRZEDWIOSNIE',DATE '1938-02-02');


CREATE TYPE pisarz AS OBJECT (
    ID_PISARZA NUMBER,
    NAZWISKO VARCHAR2(20),
    DATA_UR DATE,
    MEMBER FUNCTION ILE_KSIAZEK RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY pisarz AS
    MEMBER FUNCTION ile_ksiazek RETURN NUMBER IS
        ile NUMBER := 0;
        BEGIN
            DBMS_OUTPUT.PUT_LINE(id_pisarza);
            select count(*) into ile from ksiazki_v k where deref(k.id_pisarza).id_pisarza = SELF.id_pisarza;
            return ile;
        END ile_ksiazek;
END;
/

CREATE OR REPLACE VIEW pisarze_v OF pisarz
    WITH OBJECT IDENTIFIER(id_pisarza)
    AS SELECT * FROM pisarze;
  
CREATE TYPE ksiazka AS OBJECT (
    ID_KSIAZKI NUMBER,
    ID_PISARZA REF pisarz,
    TYTUL VARCHAR2(50),
    DATA_WYDANIA DATE,
    MEMBER FUNCTION wiek RETURN NUMBER
);
 
CREATE OR REPLACE TYPE BODY ksiazka AS
    MEMBER FUNCTION wiek RETURN NUMBER IS
        BEGIN
            RETURN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_WYDANIA);
        END wiek;
END;
/

CREATE OR REPLACE VIEW ksiazki_v OF ksiazka
    WITH OBJECT IDENTIFIER (id_ksiazki) AS
        SELECT id_ksiazki, MAKE_REF(pisarze_v,id_pisarza), tytul, data_wydania
        FROM ksiazki;


SELECT deref(id_pisarza).id_pisarza as pisarz, data_wydania, k.wiek() FROM ksiazki_v k;
SELECT id_pisarza, nazwisko, p.ile_ksiazek() FROM pisarze_v p;

--23.
CREATE TYPE AUTO AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2),
    MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY AUTO AS
    MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        WIEK NUMBER;
        WARTOSC NUMBER;
        BEGIN
            WIEK := ROUND(MONTHS_BETWEEN(SYSDATE,DATA_PRODUKCJI)/12);
            WARTOSC := CENA - (WIEK * 0.1 * CENA);
            IF (WARTOSC < 0) THEN
                WARTOSC := 0;
            END IF;
            RETURN WARTOSC;
        END WARTOSC;
END;
/

CREATE TABLE AUTA OF AUTO;

INSERT INTO AUTA VALUES (AUTO('FIAT','BRAVA',60000,DATE '1999-11-30',25000));
INSERT INTO AUTA VALUES (AUTO('FORD','MONDEO',80000,DATE '1997-05-10',45000));
INSERT INTO AUTA VALUES (AUTO('MAZDA','323',12000,DATE '2000-09-22',52000));

ALTER TYPE AUTO NOT FINAL CASCADE;

CREATE TYPE AUTO_OSOBOWE UNDER AUTO (
    LICZBA_MIEJSC NUMBER,
    KLIMATYZACJA VARCHAR2(3),
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE TYPE AUTO_CIEZAROWE UNDER AUTO (
    LADOWNOSC NUMBER,
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY AUTO_OSOBOWE AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        WARTOSC NUMBER;
        BEGIN
            IF (KLIMATYZACJA = 'tak') THEN
                WARTOSC := 1.5*CENA;
            ELSE
                WARTOSC := CENA;
            END IF;
            RETURN WARTOSC;
        END WARTOSC;
END;
/

CREATE OR REPLACE TYPE BODY AUTO_CIEZAROWE AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        WARTOSC NUMBER;
        BEGIN
            IF (LADOWNOSC > 10000) THEN
                WARTOSC := 2*CENA;
            ELSE
                WARTOSC := CENA;
            END IF;
            RETURN WARTOSC;
        END WARTOSC;
END;
/

INSERT INTO AUTA VALUES (AUTO_OSOBOWE('AUDI','A3',100,DATE '2022-01-01',100000,5,'tak'));
INSERT INTO AUTA VALUES (AUTO_OSOBOWE('NISSAN','MICRA',10000,DATE '1995-05-10',50000,4,'nie'));

INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('CITROEN','JUMPER',25000,DATE '2010-11-21',300000,8000));
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('DACIA','DOKKER',300000,DATE '1997-07-22',200000, 12000));

SELECT marka, a.wartosc() from auta a;