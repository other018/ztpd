--------------------------------------------------------------------------------
----------------- Przetwarzanie danych przestrzennych (zadania) ----------------
------------------------------------ SQL/MM -----------------------------------
--------------------------------------------------------------------------------

-------------------
--- Cwiczenie 1 ---
-------------------

--1A.
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name and prior t.owner = t.owner;

--1B.
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;

--1C.
CREATE TABLE myst_major_cities (
    fips_cntry VARCHAR2(2),
    city_name VARCHAR2(40),
    stgeom ST_POINT
);

--1D.
INSERT INTO myst_major_cities
SELECT fips_cntry, city_name, TREAT(ST_POINT.FROM_SDO_GEOM(geom) AS ST_POINT) FROM ZSBD_TOOLS.major_cities;

SELECT * FROM myst_major_cities;

-------------------
--- Cwiczenie 2 ---
-------------------

--2A.
INSERT INTO myst_major_cities
VALUES ('PL', 'Szczyrk', TREAT(ST_POINT.FROM_WKT('POINT (19.036107 49.718655)') AS ST_POINT));

--2B.
SELECT name, (ST_GEOMETRY.FROM_SDO_GEOM(geom)).GET_WKT() as WKT FROM rivers;

--2C.
select mmc.city_name, SDO_UTIL.TO_GMLGEOMETRY(mmc.stgeom.geom) GML FROM myst_major_cities mmc WHERE city_name = 'Szczyrk';

-------------------
--- Cwiczenie 3 ---
-------------------

--3A.
CREATE TABLE myst_country_boundaries (
    fips_cntry VARCHAR2(2),
    cntry_name VARCHAR2(40),
    stgeom ST_MULTIPOLYGON
);

--3B.
INSERT INTO myst_country_boundaries
SELECT fips_cntry, cntry_name, ST_MULTIPOLYGON(geom) FROM ZSBD_TOOLS.country_boundaries;

--3C.
SELECT mcb.stgeom.st_geometryType() as typ_obiektu, count(*)
FROM myst_country_boundaries mcb
GROUP BY(mcb.stgeom.st_geometryType());

--3D.
SELECT mcb.stgeom.st_isSimple() FROM myst_country_boundaries mcb;

-------------------
--- Cwiczenie 4 ---
-------------------

--4A.
SELECT mcb.cntry_name, count(*) from myst_country_boundaries mcb, myst_major_cities mmc
    WHERE (mmc.stgeom).st_within(mcb.stgeom) = 1
    GROUP BY mcb.cntry_name;

select mmc.city_name, mmc.stgeom.geom, mmc.stgeom.geom.sdo_srid from myst_major_cities mmc;

UPDATE myst_major_cities
    SET stgeom = TREAT(ST_POINT.FROM_WKT('POINT (19.036107 49.718655)', 8307) AS ST_POINT)
    WHERE city_name = 'Szczyrk';

SELECT mcb.cntry_name, count(*) from myst_country_boundaries mcb, myst_major_cities mmc
    WHERE (mmc.stgeom).st_within(mcb.stgeom) = 1
    GROUP BY mcb.cntry_name;

--4B.
select A.CNTRY_NAME as A_NAME, B.CNTRY_NAME as B_NAME
    from MYST_COUNTRY_BOUNDARIES A, MYST_COUNTRY_BOUNDARIES B
    where B.cntry_name = 'Czech Republic' and A.STGEOM.ST_Touches(B.STGEOM) = 1;
    
--4C.
select A.CNTRY_NAME as A_NAME, B.CNTRY_NAME as B_NAME
    from MYST_COUNTRY_BOUNDARIES A, MYST_COUNTRY_BOUNDARIES B
    where B.cntry_name = 'Czech Republic' AND A.STGEOM.ST_Touches(B.STGEOM) = 1;

--4D.
select TREAT(A.STGEOM.ST_UNION(B.STGEOM) as ST_POLYGON).ST_AREA() powierzchnia
    from MYST_COUNTRY_BOUNDARIES A, MYST_COUNTRY_BOUNDARIES B
    where A.CNTRY_NAME = 'Czech Republic' and B.CNTRY_NAME = 'Slovakia';

--4E.
select mcb.STGEOM WEGRY, mcb.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(wb.GEOM)) WEGRY_BEZ
from MYST_COUNTRY_BOUNDARIES mcb, WATER_BODIES wb
where mcb.CNTRY_NAME = 'Hungary' and wb.name = 'Balaton';

-------------------
--- Cwiczenie 5 ---
-------------------

--5A.
EXPLAIN PLAN FOR
select mcb.CNTRY_NAME, count(*)
	from MYST_COUNTRY_BOUNDARIES mcb, MYST_MAJOR_CITIES mmc
	where SDO_WITHIN_DISTANCE(mmc.STGEOM, mcb.STGEOM,'distance=100 unit=km') = 'TRUE'
		and mcb.CNTRY_NAME = 'Poland'
    group by mcb.CNTRY_NAME;
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

--5B.
INSERT INTO USER_SDO_GEOM_METADATA VALUES (
    'MYST_MAJOR_CITIES',
    'STGEOM',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
        MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1)
    ),
    8307
);

INSERT INTO USER_SDO_GEOM_METADATA VALUES (
    'MYST_COUNTRY_BOUNDARIES',
    'STGEOM',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
        MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1)
    ),
    8307
);

--5C.
create index MYST_COUNTRY_BOUNDARIES_IDX
    on MYST_COUNTRY_BOUNDARIES(STGEOM)
    indextype IS MDSYS.SPATIAL_INDEX;

create index MYST_MAJOR_CITIES_IDX
    on MYST_MAJOR_CITIES(STGEOM)
    indextype IS MDSYS.SPATIAL_INDEX;

--5D.
EXPLAIN PLAN FOR
select mcb.CNTRY_NAME, count(*)
	from MYST_COUNTRY_BOUNDARIES mcb, MYST_MAJOR_CITIES mmc
	where SDO_WITHIN_DISTANCE(mmc.STGEOM, mcb.STGEOM,'distance=100 unit=km') = 'TRUE'
		and mcb.CNTRY_NAME = 'Poland'
    group by mcb.CNTRY_NAME;
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());
