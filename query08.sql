/*
8.  With a query, find out how many census block groups Penn's main campus
    fully contains.

*/
set search_path = public;

WITH penn_campus AS (
    SELECT ST_Envelope(ST_Collect(geog::geometry)) AS campus_geom
    FROM phl.pwd_parcels
    WHERE
        (owner1 ILIKE '%univ%penn%' OR owner1 ILIKE '%tr%univ%penn%')
        AND ST_Within(
            geog::geometry,
            ST_MakeEnvelope(-75.215, 39.945, -75.185, 39.960, 4326)
        )
)

SELECT COUNT(*)::integer AS count_block_groups
FROM census.blockgroups_2020 AS bg, penn_campus
WHERE ST_Within(bg.geog::geometry, penn_campus.campus_geom);
