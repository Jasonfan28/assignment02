/*
10. Build a stop_desc for each rail stop describing its location relative to
    the nearest Philadelphia neighborhood centroid and the cardinal direction
    from that centroid to the stop.
*/

set search_path = public;

WITH rail_stop_geog AS (
    SELECT
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography AS geog
    FROM septa.rail_stops
),

nearest_neighborhood AS (
    SELECT DISTINCT ON (rs.stop_id)
        rs.stop_id,
        rs.stop_name,
        rs.stop_lon,
        rs.stop_lat,
        rs.geog AS stop_geog,
        n.mapname AS neighborhood_name,
        ST_Centroid(n.geog::geometry)::geography AS neighborhood_centroid
    FROM rail_stop_geog AS rs
    CROSS JOIN LATERAL (
        SELECT
            n.mapname,
            n.geog
        FROM phl.neighborhoods AS n
        ORDER BY rs.geog <-> n.geog::geography
        LIMIT 1
    ) AS n
),

with_direction AS (
    SELECT
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        neighborhood_name,
        ROUND(ST_Distance(stop_geog, neighborhood_centroid)::numeric, 0) AS dist_m,
        DEGREES(
            ST_Azimuth(neighborhood_centroid::geometry, stop_geog::geometry)
        ) AS azimuth_deg
    FROM nearest_neighborhood
)

SELECT
    stop_id::integer,
    stop_name::text,
    (
        dist_m::text
        || ' meters '
        || CASE
            WHEN azimuth_deg < 22.5  OR azimuth_deg >= 337.5 THEN 'N'
            WHEN azimuth_deg < 67.5  THEN 'NE'
            WHEN azimuth_deg < 112.5 THEN 'E'
            WHEN azimuth_deg < 157.5 THEN 'SE'
            WHEN azimuth_deg < 202.5 THEN 'S'
            WHEN azimuth_deg < 247.5 THEN 'SW'
            WHEN azimuth_deg < 292.5 THEN 'W'
            ELSE 'NW'
        END
        || ' of '
        || neighborhood_name
        || ' neighborhood center'
    )::text AS stop_desc,
    stop_lon::double precision,
    stop_lat::double precision
FROM with_direction
ORDER BY stop_name;
