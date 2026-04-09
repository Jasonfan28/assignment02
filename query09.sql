/*
9.  With a query involving PWD parcels and census block groups, find the geo_id
    of the block group that contains Meyerson Hall.
    ST_MakePoint() and similar point-construction functions are not allowed.
*/

set search_path = public;

SELECT bg.geoid AS geo_id
FROM phl.pwd_parcels AS p
JOIN census.blockgroups_2020 AS bg
    ON ST_Within(p.geog::geometry, bg.geog::geometry)
WHERE p.address = '220-30 S 34TH ST';

