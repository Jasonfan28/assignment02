/*
4.  Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips.

    _Your query should run in under two minutes._

    >_**HINT**: The `ST_MakeLine` function is useful here. You can see an example of how you could use it at [this MobilityData walkthrough](https://docs.mobilitydb.com/MobilityDB-workshop/master/ch04.html#:~:text=INSERT%20INTO%20shape_geoms) on using GTFS data. If you find other good examples, please share them in Slack._

    >_**HINT**: Use the query planner (`EXPLAIN`) to see if there might be opportunities to speed up your query with indexes. For reference, I got this query to run in about 15 seconds._

    >_**HINT**: The `row_number` window function could also be useful here. You can read more about window functions [in the PostgreSQL documentation](https://www.postgresql.org/docs/9.1/tutorial-window.html). That documentation page uses the `rank` function, which is very similar to `row_number`. For more info about window functions you can check out:_
    >*   📑 [_An Easy Guide to Advanced SQL Window Functions_](https://medium.com/data-science/a-guide-to-advanced-sql-window-functions-f63f2642cbf9) in Towards Data Science, by Julia Kho
    >*   🎥 [_SQL Window Functions for Data Scientists_](https://www.youtube.com/watch?v=e-EL-6Vnkbg) (and a [follow up](https://www.youtube.com/watch?v=W_NBnkLLh7M) with examples) on YouTube, by Emma Ding
    >*   📖 Chapter 16: Analytic Functions in Learning SQL, 3rd Edition for a deep dive (see the [books](https://github.com/Weitzman-MUSA-GeoCloud/course-info/tree/main/week01#books) listed in week 1, which you can access on [O'Reilly for Higher Education](http://pwp.library.upenn.edu.proxy.library.upenn.edu/loggedin/pwp/pw-oreilly.html))
    

    **Structure:**
    ```sql
    (
        route_short_name text,  -- The short name of the route
        trip_headsign text,  -- Headsign of the trip
        shape_length numeric  -- Length of the trip in meters, rounded to the nearest meter
    )
    ```
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