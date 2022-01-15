--------------------------------------------------------------------------------
----------------- Przetwarzanie danych przestrzennych (zadania) ----------------
------------------------ Wprowadzenie, typ SDO_GEOMETRY ------------------------
--------------------------------------------------------------------------------

--1A.
--DROP TABLE figury;
CREATE TABLE figury (
    id NUMBER(1),
    ksztalt MDSYS.SDO_GEOMETRY
);

select * from figury;

--1B.
-- 4 - Circle type. Described by three points, all on the circumference of the circle.
INSERT INTO figury
    VALUES(1, MDSYS.SDO_GEOMETRY(2003, NULL, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,4), MDSYS.SDO_ORDINATE_ARRAY(5,7, 3,5, 5,3) ) );

-- 3 - Rectangle type (sometimes called optimized rectangle).
--     A bounding rectangle such that only two points, the lower-left and the upper-right, are required to describe it.
INSERT INTO figury
    VALUES(2, MDSYS.SDO_GEOMETRY(2003, NULL, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3), MDSYS.SDO_ORDINATE_ARRAY(1,1, 5,5) ) );


INSERT INTO figury
    VALUES(3, MDSYS.SDO_GEOMETRY(2002, NULL, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1,4,3, 1,2,1, 3,2,1, 5,2,2), MDSYS.SDO_ORDINATE_ARRAY(3,2, 6,2,  7,3,  8,2, 7,1) ) );


--1C.
INSERT INTO figury
    VALUES(4, MDSYS.SDO_GEOMETRY(2003, NULL, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,4), MDSYS.SDO_ORDINATE_ARRAY(5,5, 6,5, 7,5) ) );

--1D.
SELECT id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.005)
   FROM figury;
  
--1E.
DELETE FROM figury WHERE id=4;

--1F.
COMMIT;