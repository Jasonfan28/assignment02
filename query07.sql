7.  What are the _bottom five_ neighborhoods according to your accessibility metric?

    **Both #6 and #7 should have the structure:**
    ```sql
    (
      neighborhood_name text,  -- The name of the neighborhood
      accessibility_metric ...,  -- Your accessibility metric value
      num_bus_stops_accessible integer,
      num_bus_stops_inaccessible integer
    )
    ```