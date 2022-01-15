--------------------------------------------------------------------------------
----------------------------- Duze obiekty tekstowe ----------------------------
--------------------------------------------------------------------------------

--1.
--DROP TABLE dokumenty;
CREATE TABLE dokumenty (
    id NUMBER(12) PRIMARY KEY,
    dokument CLOB
)

--2.
DECLARE
    counter NUMBER;
BEGIN
    INSERT INTO dokumenty VALUES (1, '');
    FOR counter IN 1..10000
    LOOP
        UPDATE dokumenty SET dokument = dokument || 'Oto tekst. ' WHERE id=1;
        COMMIT;
    END LOOP;
END;
/

--3a.
SELECT * FROM dokumenty;

--3b.
SELECT UPPER(dokument) FROM dokumenty;

--3c.
SELECT LENGTH(dokument) FROM dokumenty;

--3d.
SELECT dbms_lob.getlength(dokument) FROM dokumenty;

--3e.
SELECT SUBSTR(dokument, 5, 1000) FROM dokumenty;

--3f.
SELECT dbms_lob.SUBSTR(dokument, 1000, 5) FROM dokumenty;

--4.
INSERT INTO dokumenty VALUES (2, EMPTY_CLOB());

--5.
INSERT INTO dokumenty VALUES (3, NULL);
COMMIT;

--6.
SELECT * FROM dokumenty;
SELECT UPPER(dokument) FROM dokumenty;
SELECT LENGTH(dokument) FROM dokumenty;
SELECT dbms_lob.getlength(dokument) FROM dokumenty;
SELECT SUBSTR(dokument, 5, 1000) FROM dokumenty;
SELECT dbms_lob.SUBSTR(dokument, 1000, 5) FROM dokumenty;

--7.
SELECT * FROM all_directories;

--8.
DECLARE
    lobd clob;
    fils BFILE := BFILENAME('ZSBD_DIR', 'dokument.txt');
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn integer := null;
BEGIN
    SELECT dokument INTO lobd FROM dokumenty
        WHERE id=2
        FOR UPDATE;
        
    DBMS_LOB.FILEOPEN(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADCLOBFROMFILE(lobd, fils, DBMS_LOB.LOBMAXSIZE, doffset, soffset, 0, langctx, warn);
    DBMS_LOB.FILECLOSE(fils);

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Status operacji:'||warn);
END;
/

--9.
UPDATE dokumenty SET dokument=TO_CLOB(BFILENAME('ZSBD_DIR', 'dokument.txt')) WHERE id=3;
COMMIT;

--10.
SELECT * FROM dokumenty;

--11.
SELECT dbms_lob.getlength(dokument) FROM dokumenty;

--12.
DROP TABLE dokumenty;

--13.
CREATE OR REPLACE PROCEDURE CLOB_CENSOR (
    big_file IN OUT CLOB,
    replace_word IN varchar2
)
IS
    word_length number (30);
    replace_dots varchar2(100);
    place number(30);
BEGIN
    word_length := length(replace_word);
    replace_dots := LPAD('.', word_length, '.');
    place := DBMS_LOB.INSTR(big_file, replace_word, 1, 1);
    
    WHILE place IS NOT NULL AND place != 0
    LOOP
        --dbms_output.put_line(place);
        DBMS_LOB.WRITE(big_file, word_length, place, replace_dots);
        place := DBMS_LOB.INSTR(big_file, replace_word, place, 1);
    END LOOP;
END CLOB_CENSOR;
/

--14.
CREATE TABLE biographies AS SELECT * FROM ZSBD_TOOLS.BIOGRAPHIES;
SELECT * FROM biographies;


DECLARE
    biography CLOB;
BEGIN
    SELECT bio INTO biography FROM biographies WHERE id=1 FOR UPDATE;
    CLOB_CENSOR(biography, 'Cimrman');
END;
/

SELECT * FROM biographies;

--15.
DROP TABLE biographies;
