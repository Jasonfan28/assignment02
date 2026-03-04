/*
3.  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
pair each parcel with its closest bus stop. 
The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. 
Order by distance (largest on top).

    _Your query should run in under two minutes._

    >_**HINT**: This is a [nearest neighbor](https://postgis.net/workshops/postgis-intro/knn.html) problem.

    **Structure:**
    ```sql
    (
        parcel_address text,  -- The address of the parcel
        stop_name text,  -- The name of the bus stop
        distance numeric  -- The distance apart in meters, rounded to two decimals
    )
    ```
*/

SELECT 
    pwd_parcel.address AS parcel_address,
    knn.stop_name,
    ROUND(knn.distance::numeric, 2) AS distance
FROM phl.pwd_parcels as pwd_parcel
CROSS JOIN 
    LATERAL (
        SELECT 
            stops.stop_name,
            pwd_parcel.geog::geography <-> stops.geog::geography as distance
        FROM septa.bus_stops AS stops
        ORDER BY distance asc
        LIMIT 1
    ) AS knn
ORDER BY distance DESC;
