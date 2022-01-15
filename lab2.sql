--------------------------------------------------------------------------------
----------------------------- Duze obiekty binarne -----------------------------
--------------------------------------------------------------------------------

--1.
--DROP TABLE movies;

CREATE TABLE movies (
    ID NUMBER(12) PRIMARY KEY,
    TITLE VARCHAR2(400) NOT NULL,
    CATEGORY VARCHAR2(50),
    YEAR CHAR(12),
    CAST VARCHAR2(4000),
    DIRECTOR VARCHAR2(4000),
    STORY VARCHAR2(4000),
    PRICE NUMBER(5,2),
    COVER BLOB,
    MIME_TYPE VARCHAR2(50)
);

DESCRIBE movies;

--2.
SELECT * FROM descriptions;
SELECT * FROM covers;

SELECT * FROM descriptions
    LEFT JOIN covers ON (covers.movie_id = descriptions.id);

INSERT INTO movies
    SELECT id, title, category, year, cast, director, story, price, image, mime_type FROM descriptions
        LEFT JOIN covers ON (covers.movie_id = descriptions.id);

SELECT * FROM movies;

--3.
SELECT id, title FROM movies WHERE cover IS NULL;

--4.
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS fileSize FROM movies WHERE cover IS NOT NULL;

--5.
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS fileSize FROM movies WHERE cover IS NULL;
-- wartosc kolumny filesize -> (null)

--6.
SELECT * FROM all_directories;
--BFILENAME('ZSBD_DIR', 'eagles.jpg');
--BFILENAME('ZSBD_DIR', 'escape.jpg');

--7.
UPDATE movies SET cover=EMPTY_BLOB(), mime_type='image/jpeg' WHERE id=66;
COMMIT;
SELECT * FROM movies;

--8.
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS fileSize FROM movies WHERE id IN (65,66);

--9.
DECLARE
    lobd blob;
    fils BFILE := BFILENAME('ZSBD_DIR', 'escape.jpg');
BEGIN
    SELECT cover INTO lobd FROM movies
        WHERE id=66
        FOR UPDATE;
    DBMS_LOB.FILEOPEN(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(lobd, fils, DBMS_LOB.GETLENGTH(fils));
    DBMS_LOB.FILECLOSE(fils);
    
    COMMIT;
END;
/

--10.
CREATE TABLE temp_covers (
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);

--11.
INSERT INTO temp_covers VALUES
    (65, BFILENAME('ZSBD_DIR', 'eagles.jpg'), 'image/png');
COMMIT;

--12.
SELECT movie_id, DBMS_LOB.GETLENGTH(image) AS fileSize from temp_covers;

--13.
DECLARE
    lobd blob;
    fils BFILE;
    filetype varchar2(50);
BEGIN
    SELECT image, mime_type INTO fils, filetype FROM temp_covers WHERE movie_id = 65;

    dbms_lob.createtemporary(lobd,TRUE);
    
    DBMS_LOB.FILEOPEN(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(lobd, fils, DBMS_LOB.GETLENGTH(fils));
    DBMS_LOB.FILECLOSE(fils);

    UPDATE movies SET cover=lobd, mime_type = filetype WHERE id=65;
    
    dbms_lob.freetemporary(lobd);

    COMMIT;
END;
/

--14.
SELECT id, DBMS_LOB.GETLENGTH(cover) AS fileSize FROM movies WHERE id IN (65,66);

--15.
DROP TABLE movies;
DROP TABLE temp_covers;