2.  Which **eight** bus stops have the smallest population above 500 people _inside of Philadelphia_ within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of `42101` -- that's `42` for the state of PA, and `101` for Philadelphia county)?

    **The queries to #1 & #2 should generate results with a single row, with the following structure:**

    ```sql
    (
        stop_id text, -- The ID of the station
        stop_name text, -- The name of the station
        estimated_pop_800m integer -- The population within 800 meters
    )
    ```