/*
7.  What are the bottom five neighborhoods according to your accessibility metric?

    Accessibility metric: ratio of accessible stops (wheelchair_boarding = 1) to
    all stops with known status (wheelchair_boarding = 1 or 2).
    Only neighborhoods that have at least one stop with known status are included.
*/

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
WHERE (num_bus_stops_accessible + num_bus_stops_inaccessible) > 0
ORDER BY accessibility_metric ASC
LIMIT 5;
