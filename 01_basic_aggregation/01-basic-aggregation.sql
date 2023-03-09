CREATE TABLE `bq_nested_repeated_fields_demo.01_basic_aggregation` (
  user_id INT64,
  activity_date DATE,
  sport STRING
);
INSERT INTO `bq_nested_repeated_fields_demo.01_basic_aggregation` (user_id, activity_date, sport)
SELECT 
  distinct
  MOD(ROW_NUMBER() OVER(), 10) + 1 AS user_id,
  DATE_SUB(CURRENT_DATE(), INTERVAL cast(RAND() * 10 as int64) DAY) AS activity_date,
  CASE MOD(ROW_NUMBER() OVER(), 4)
    WHEN 0 THEN "football"
    WHEN 1 THEN "tennis"
    WHEN 2 THEN "formula 1"
    WHEN 3 THEN "rugby"
  END AS sport
FROM 
  UNNEST(GENERATE_ARRAY(1, 50)) AS row
order by user_id, activity_date
;
select *
from `bq_nested_repeated_fields_demo.01_basic_aggregation`
order by user_id, activity_date
;
-- Now we've got a flat table, and we can query just like mysql or any other RDBMS
-- What if we want to aggregate that into a user summary?
-- Something we want to be easy to use for aggregated statistics.
-- Say we have an API that wants to fetch this data for a single user, and they just want all of the relevant data in a single row.
-- We want to aggregate this, so we might do something like this:
;
select
  user_id,
  count(activity_date) as active_days,
  count(distinct activity_date) as distinct_active_days,
  max(activity_date) as last_active_date,
  date_diff(max(activity_date), min(activity_date), day) as activity_days_spread
from `bq_nested_repeated_fields_demo.01_basic_aggregation`
group by user_id
order by user_id
;
-- this is helpful, we can use this to see how many users we've got (it's just the count of rows)
-- we can calculate average days active per user, and see which users have been active recently
-- but we've lost the detail within that aggregation.
-- what if we could both aggregate, and keep the detail?
;
create or replace table `bq_nested_repeated_fields_demo.02_aggregated_table` as
select
  user_id,
  array_agg(activity_date order by activity_date) as active_days,
  array_agg(sport) as sports_viewed
from `bq_nested_repeated_fields_demo.01_basic_aggregation`
group by user_id
order by user_id
;
-- look at json output
-- each record contains 2 arrays, or repeated fields. Not nested, just repeated, just many dates/strings.
-- How can we query this?
-- Don't be tempted to just unnest
;
select
  -- a single row from your main table
  main_table.user_id,
  main_table.active_days,
  main_table.sports_viewed,

  -- has been expanded to many rows with the unnest.
  act_d,
from `bq_nested_repeated_fields_demo.02_aggregated_table` as main_table,
    unnest(main_table.active_days) as act_d
order by user_id, act_d
;
-- If you've only got one nested field, and only want to use that one nested field, this might be fine
-- but more likely than not, if you've got one nested field, you'll have many.
-- what if your analysis also wanted to take advantage of sports viewed?
;
select
  -- a single row from your main table
  main_table.user_id,
  main_table.active_days,
  main_table.sports_viewed,

  -- has been expanded to many rows with the unnest.
  act_d,
  sp
from `bq_nested_repeated_fields_demo.02_aggregated_table` as main_table,
    unnest(main_table.active_days) as act_d,
    unnest(main_table.sports_viewed) as sp
where user_id = 1
order by user_id, act_d, sp
;
-- we can query the array, without needing to unnest
;
select
  -- single row
  user_id,
  active_days,
  sports_viewed,


  --
  (select as struct
    count(distinct ad) as distinct_active_days,
    min(ad) as first_active_date,
    max(ad) as last_active_date
   from unnest(active_days) as ad
  ) as active_day_summary,

  (select as struct
    sport as most_viewed_sport,
    count(*) as sport_views
  from unnest(sports_viewed) as sport
  group by sport
  order by sport_views desc
  limit 1
  ) as sport_summary

from `bq_nested_repeated_fields_demo.02_aggregated_table`
order by user_id
;
-- still only got one row per user, but can do complex analysis with that one row!
-- check the JSON output
;
-- lastly, there's one thing we can't do, marry the sports viewed, with the date they were viewed.
-- this is where nested and repeated records come in.
-- we might, for example, want to know what is the most recent sport viewed by a user, but we cant tell this yet.
;
select
  user_id,
  struct(activity_date, sport) as sport_view -- this is now a struct, rather than 2 unrelated fields
from `bq_nested_repeated_fields_demo.01_basic_aggregation`
order by user_id, activity_date, sport
;
-- interestingly, we can aggregate a struct!
;
create or replace table `bq_nested_repeated_fields_demo.03_nested_repeated_table` as
select
  user_id,
  array_agg(
    struct(activity_date, sport)
    order by activity_date, sport
  ) as sport_views
from `bq_nested_repeated_fields_demo.01_basic_aggregation`
group by user_id
order by user_id
;
-- this looks ALMOST identical to our previous table, but in this instance, the 2 arrays are twinned together,
-- so now instead of 2 arrays of individual values, we have one array of objects, each with 2 fields
-- This is effectively a mini table, within a single row
;
select
  -- single row for user
  user_id,
  sport_views,

  --complex analysis, made simple
  (select
      sport
   from unnest(sport_views)
   order by activity_date desc
   limit 1
  ) as most_recent_sport
from `bq_nested_repeated_fields_demo.03_nested_repeated_table`
order by user_id
;
