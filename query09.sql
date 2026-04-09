/*
9.  With a query involving PWD parcels and census block groups, find the geo_id
    of the block group that contains Meyerson Hall.
    ST_MakePoint() and similar point-construction functions are not allowed.

    Approach: locate the Meyerson Hall parcel in phl.pwd_parcels by its street
    address (210 S 34TH ST), then find the census block group whose geography
    contains that parcel's geometry.
*/

SELECT bg.geoid AS geo_id
FROM phl.pwd_parcels AS p
JOIN census.blockgroups_2020 AS bg
    ON ST_Within(p.geog::geometry, bg.geog::geometry)
WHERE p.address = '210 S 34TH ST';
