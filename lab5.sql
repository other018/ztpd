--------------------------------------------------------------------------------
----------------- Przetwarzanie danych przestrzennych (zadania) ----------------
--------------------- Metadane, indeksowanie, przetwarzanie --------------------
--------------------------------------------------------------------------------

-------------------
--- Cwiczenie 1 ---
-------------------

--1A.
INSERT INTO USER_SDO_GEOM_METADATA
VALUES ('figury', 'ksztalt', MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('X', 1, 8, 0.01), MDSYS.SDO_DIM_ELEMENT('Y', 1, 7, 0.01)), null);

SELECT META.TABLE_NAME, META.COLUMN_NAME, META.SRID, DIM.*
FROM USER_SDO_GEOM_METADATA META, TABLE(META.DIMINFO) DIM;

--1B.
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0) FROM dual;

--1C.
CREATE INDEX figury_idx on figury(ksztalt) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

--1D. nie, "Operator SDO_FILTER, ktory wykorzystuje jedynie pierwsza faza zapytania, czyli daje w wyniku zbior "kandydatow", dla indeksu r-tree uzna, ze z punktem 3,3 maja "cos wspolnego" wszystkie 3 geometrie."
select ID from FIGURY where SDO_FILTER(KSZTALT, SDO_GEOMETRY(2001, null, SDO_POINT_TYPE(3, 3, null), null, null)) = 'TRUE';

--1E. tak, teraz odpowiada
select ID from FIGURY where SDO_RELATE(KSZTALT, SDO_GEOMETRY(2001, null, SDO_POINT_TYPE(3, 3, null), null, null), 'mask=ANYINTERACT') = 'TRUE';

-------------------
--- Cwiczenie 2 ---
-------------------

SELECT * FROM COUNTRY_BOUNDARIES;
SELECT * FROM MAJOR_CITIES;
SELECT * FROM STREETS_AND_RAILROADS;
SELECT * FROM WATER_BODIES;
SELECT * FROM RIVERS;

--2A.
select MC.CITY_NAME as miasto, SDO_NN_DISTANCE(1) as odl
    from (SELECT * FROM MAJOR_CITIES WHERE city_name != 'Warsaw') MC
    where SDO_NN(GEOM, (select GEOM from MAJOR_CITIES WHERE city_name = 'Warsaw'),'sdo_num_res=10 unit=km',1) = 'TRUE';

--2B.
select MC.CITY_NAME as miasto
    from (SELECT * FROM MAJOR_CITIES WHERE city_name != 'Warsaw') MC
    where SDO_WITHIN_DISTANCE(GEOM, (select GEOM from MAJOR_CITIES WHERE city_name = 'Warsaw'),'distance=100 unit=km') = 'TRUE';

--2C.
select cb.cntry_name as kraj, MC.CITY_NAME as miasto
    from COUNTRY_BOUNDARIES CB, MAJOR_CITIES MC
    where SDO_RELATE(MC.GEOM, CB.GEOM, 'mask=INSIDE') = 'TRUE'
    and cb.cntry_name='Slovakia';

--2D.
select b.cntry_name, SDO_GEOM.SDO_DISTANCE(A.GEOM, B.GEOM, 1, 'unit=km') ODL
    from COUNTRY_BOUNDARIES A, COUNTRY_BOUNDARIES B
    where SDO_RELATE(A.geom, B.geom,'mask=TOUCH') != 'TRUE'
    and A.cntry_name = 'Poland' and B.cntry_name != 'Poland';
    
-------------------
--- Cwiczenie 3 ---
-------------------

--3A.
select B.CNTRY_NAME, SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=km') as odleglosc
    from COUNTRY_BOUNDARIES A, COUNTRY_BOUNDARIES B
    where A.CNTRY_NAME = 'Poland'
    and SDO_RELATE(A.geom, B.geom,'mask=TOUCH') = 'TRUE';
    
--3B.
SELECT * FROM (
    select A.CNTRY_NAME, ROUND(SDO_GEOM.sdo_area(A.GEOM, 1, 'unit=SQ_KM')) as POWIERZCHNIA
    from COUNTRY_BOUNDARIES A order by powierzchnia DESC
) result where ROWNUM = 1;

--3C.
select SDO_GEOM.SDO_AREA(
    SDO_GEOM.SDO_MBR(SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 1)),
    1,
    'unit=SQ_KM'
) SQ_KM
    from MAJOR_CITIES A, MAJOR_CITIES B
    where A.city_name='Lodz' and B.city_name='Warsaw';

--3D.
select SDO_GEOM.SDO_UNION(
    (SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE cntry_name='Poland'),
    (SELECT GEOM FROM MAJOR_CITIES WHERE city_name='Prague'),
    1
).GET_GTYPE() as gtype from dual;

--3E.
SELECT * FROM (
    select CB.cntry_name, MC.city_name, SDO_GEOM.SDO_DISTANCE(
        SDO_GEOM.SDO_CENTROID(CB.GEOM, 1),
        MC.GEOM,
        1,
        'unit=km'
    ) as dist    
        from COUNTRY_BOUNDARIES CB, MAJOR_CITIES MC
        WHERE MC.cntry_name = CB.cntry_name
        order by dist ASC
) result
    WHERE ROWNUM = 1;
    
--3F.
select R.name, sum(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(B.GEOM, R.GEOM, 1), 1, 'unit=km'))
    from COUNTRY_BOUNDARIES B, RIVERS R
    where B.CNTRY_NAME = 'Poland'
        AND SDO_GEOM.RELATE(B.GEOM, 'ANYINTERACT', R.GEOM, 1) != 'FALSE'
    GROUP BY R.name;
