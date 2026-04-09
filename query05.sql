/*
5.  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use
    OpenDataPhilly's neighborhood dataset along with an appropriate dataset from
    the Septa GTFS bus feed.
*/

set search_path = public;

WITH stop_neighborhood AS (
    SELECT
        n.mapname AS neighborhood_name,
        s.stop_id,
        s.wheelchair_boarding
    FROM phl.neighborhoods AS n
    JOIN septa.bus_stops AS s
        ON ST_Within(s.geog::geometry, n.geog::geometry)
),

neighborhood_stats AS (
    SELECT
        neighborhood_name,
        COUNT(*) AS total_stops,
        SUM(CASE WHEN wheelchair_boarding = 1 THEN 1 ELSE 0 END)::integer AS num_bus_stops_accessible,
        SUM(CASE WHEN wheelchair_boarding = 2 THEN 1 ELSE 0 END)::integer AS num_bus_stops_inaccessible
    FROM stop_neighborhood
    GROUP BY neighborhood_name
)

SELECT
    neighborhood_name,
    ROUND(
        num_bus_stops_accessible::numeric
        / NULLIF(num_bus_stops_accessible + num_bus_stops_inaccessible, 0),
        4
    ) AS accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM neighborhood_stats
ORDER BY accessibility_metric DESC NULLS LAST;
