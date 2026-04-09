/*
4.  Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips.

    _Your query should run in under two minutes._

*/

set search_path = public;

WITH shape_geoms AS (
    SELECT
        shape_id,
        ST_MakeLine(
            ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326) 
            ORDER BY shape_pt_sequence
        )::geography AS shape_geom
    FROM septa.bus_shapes
    GROUP BY shape_id
),
shape_lengths AS (
    SELECT
        shape_id,
        ST_Length(shape_geom) AS shape_length
    FROM shape_geoms
),
longest_trips_per_route AS (
    SELECT
        r.route_short_name,
        t.trip_headsign,
        sl.shape_length,
        ROW_NUMBER() OVER (
            PARTITION BY r.route_short_name 
            ORDER BY sl.shape_length DESC
        ) AS rn
    FROM septa.bus_trips t
    JOIN septa.bus_routes r ON t.route_id = r.route_id
    JOIN shape_lengths sl ON t.shape_id = sl.shape_id
)

SELECT 
    route_short_name::text,
    trip_headsign::text,
    ROUND(shape_length::numeric, 0) AS shape_length
FROM longest_trips_per_route
WHERE rn = 1
ORDER BY shape_length DESC
LIMIT 2;