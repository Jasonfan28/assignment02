/*
8.  With a query, find out how many census block groups Penn's main campus
    fully contains.

    Dataset chosen: phl.pwd_parcels filtered to parcels owned by the University
    of Pennsylvania and located within the University City / West Philadelphia
    area (roughly bounded by the Schuylkill River to the east, 40th St to the
    west, Market St to the north, and Baltimore Ave to the south). The union of
    those parcels forms the campus boundary used below.
*/

WITH penn_campus AS (
    SELECT ST_Union(geog::geometry)::geography AS campus_geog
    FROM phl.pwd_parcels
    WHERE
        UPPER(owner1) LIKE '%UNIVERSITY OF PENNSYLVANIA%'
        AND ST_Within(
            geog::geometry,
            ST_MakeEnvelope(-75.215, 39.945, -75.185, 39.960, 4326)
        )
)

SELECT COUNT(*)::integer AS count_block_groups
FROM census.blockgroups_2020 AS bg, penn_campus
WHERE ST_Within(bg.geog::geometry, penn_campus.campus_geog::geometry);
