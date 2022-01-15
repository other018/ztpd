--------------------------------------------------------------------------------
----------------- Przetwarzanie danych przestrzennych (zadania) ----------------
------------------------ Linear Referencing System (LRS) -----------------------
--------------------------------------------------------------------------------

-------------------
--- Cwiczenie 1 ---
-------------------

--1A.
--DROP TABLE a6_lrs;
CREATE TABLE A6_LRS (
    geom SDO_GEOMETRY
);

--1B.
--*ID - 56
INSERT INTO A6_LRS
SELECT geom FROM (
    SELECT sar.geom, round(SDO_GEOM.SDO_DISTANCE(sar.geom, mc.geom, 1, 'unit=km')) odl
        from major_cities mc, STREETS_AND_RAILROADS sar
        WHERE mc.city_name = 'Koszalin'
) res where odl < 10;

--1C.
select SDO_GEOM.SDO_LENGTH(GEOM, 1, 'unit=km') DISTANCE, ST_LINESTRING(GEOM).ST_NUMPOINTS() ST_NUMPOINTS
from A6_LRS;

--1D.
UPDATE A6_LRS SET geom=SDO_LRS.CONVERT_TO_LRS_GEOM(GEOM, 0, 276.681);
--select LRS.GEOM LRS_GEOM, SR.GEOM from A6_LRS LRS, STREETS_AND_RAILROADS SR where SR.ID = 56;

--1E.
SELECT lrs.geom.SDO_SRID FROM a6_lrs lrs;
SELECT lrs.geom.SDO_ORDINATES FROM a6_lrs lrs;

INSERT INTO USER_SDO_GEOM_METADATA VALUES
('A6_LRS', 'GEOM', MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1),MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1)),8307);

--1F.
CREATE INDEX a6_lrs_idx ON A6_LRS(geom) INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-------------------
--- Cwiczenie 2 ---
-------------------

--2A.
select SDO_LRS.VALID_MEASURE(GEOM, 500) VALID_500
from A6_LRS;

--2B.
SELECT SDO_LRS.GEOM_SEGMENT_END_PT(GEOM) END_PT
from A6_LRS;

--2C.
select SDO_LRS.LOCATE_PT(GEOM, 150, 0) KM150
from A6_LRS;

--2D.
select SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160) as cliped
from A6_LRS;

--2E.
SELECT SDO_LRS.GET_NEXT_SHAPE_PT(lrs.geom, mc.geom) WJAZD_NA_A6
    from a6_lrs lrs, major_cities mc
    WHERE mc.city_name = 'Slupsk';
        
--2F.
--SDO_LRS.OFFSET_GEOM_SEGMENT(
--     geom_segment  IN SDO_GEOMETRY,
--     dim_array     IN SDO_DIM_ARRAY,
--     start_measure IN NUMBER,
--     end_measure   IN NUMBER,
--     offset        IN NUMBER
--     [, unit       IN VARCHAR2]
--     ) RETURN SDO_GEOMETRY;

select SDO_GEOM.SDO_LENGTH(SDO_LRS.OFFSET_GEOM_SEGMENT(lrs.geom, M.DIMINFO, 50, 200, 50,'unit=m'), 1, 'unit=km') koszt
    from A6_LRS lrs, USER_SDO_GEOM_METADATA M
    where M.TABLE_NAME = 'A6_LRS' and M.COLUMN_NAME = 'GEOM'