# Measure-Rails-SELECT-Performance

Extract all the SELECT statements from the Rails development log and munge the queries so that they can be summarised by the type of query they are. From this you can see where most of you time is being spent.

With the example given below we can see that there are far to many calls for Sports given that there are only around 20 sports in total. Also there are only a couple of hundred competitions. 
Additionally we investigated the indexes on the markets table for `market_start_time` and `name`

     Count   Total ms     Avg ms Query
    ------ ---------- ---------- ---------------------------------------------------------------------------------------------------------
         1      929.2    929.200 SELECT events.* FROM events WHERE (classified = false) ORDER BY start_time, name
     26732    25241.4      0.944 SELECT competitions.* FROM competitions WHERE competitions.id = x ORDER BY name LIMIT x
     26732    20008.9      0.748 SELECT sports.* FROM sports WHERE sports.id = x ORDER BY name LIMIT x
     26670    81627.6      3.061 SELECT markets.* FROM markets WHERE markets.event_id = x ORDER BY market_start_time, name
     23973    19877.4      0.829 SELECT alternate_events.* FROM alternate_events WHERE alternate_events.id = x ORDER BY start_time LIMIT x
    ------ ---------- ---------- ---------------------------------------------------------------------------------------------------------
    104108   147684.5      1.419 

And here are the results

     Count   Total ms     Avg ms Query
    ------ ---------- ---------- ----------------------------------------------------------------------------------------------------------
         1       22.2     22.200 SELECT sports.* FROM sports ORDER BY name
         1       37.8     37.800 SELECT competitions.* FROM competitions ORDER BY name
         1      783.5    783.500 SELECT events.* FROM events WHERE (classified = false) ORDER BY start_time, name
     30546    62106.5      2.033 SELECT markets.* FROM markets WHERE markets.event_id = x ORDER BY market_start_time, name
     28113    21703.8      0.772 SELECT alternate_events.* FROM alternate_events WHERE alternate_events.id = x ORDER BY start_time LIMIT x
    ------ ---------- ---------- ---------------------------------------------------------------------------------------------------------
     58662    84653.8      1.443
