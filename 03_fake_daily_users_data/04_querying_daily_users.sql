-- how many users did we have on a given day?
select
  date,
  count(*)
from `bq_nested_repeated_fields_demo.daily_users`
where date >= "2022-01-01"
group by date
order by date asc
;
-- how many users looked at formula 1 on given day?
select
  count(*)
from `bq_nested_repeated_fields_demo.daily_users`
where date = "2022-01-01"
and exists(select sport from unnest(views) where sport = "Formula 1")
;
-- how many users looked at formula 1 EVER?
select
  count(distinct fullVisitorId)
from `bq_nested_repeated_fields_demo.daily_users`
where date >= "2022-01-01"
and exists(select sport from unnest(views) where sport = "Formula 1")
;
-- how many users looked at each sport?
select
  sport,
  count(*)
from `bq_nested_repeated_fields_demo.daily_users`,
     unnest(views)
where date >= "2022-01-01"
group by sport
;
-- how many pageviews do we have for formula 1, where the user uses our app during the grid walk?
select
  sport,
  competition_name,
  state,
  sum(st.stateTotal.hits) as totalHits,
  sum(st.stateTotal.pageViews) as pageViews,
  sum(st.stateTotal.secondsOnEventState) as secondsOnEventState
from `bq_nested_repeated_fields_demo.daily_users` as du,
     unnest(views) as v,
     unnest(competitions) as c,
     unnest(sportingEvents) as se,
     unnest(sportingEventStateDetails) as st
where date >= "2022-01-01"
and sport = "Formula 1"
and state = "grid walk"
group by sport, competition_name, state
;
-- just the users based in the US?
-- users who have visited more than one country this month?
-- just the users who are visiting for the first time today?
-- just the users who live near silverstone?
-- users with more than 3 sessions a day?
-- users with a propensity to click on adverts?
-- users who are back today for the first time in more than a month?
-- how many users had did not look at football and had more than 10 minutes on our app?

-- All possible, without any joins! The joins have already been done, so concerns about join performance all go out the window.
-- This granularity would previously have taken saveral tables to join, and expensive join operations taking a long time
-- but this query will run a lot faster, over petabytes of data, very efficiently!

-- You can make this as complex or simple as your business demands, but your analysts can then write queries in less time, that are much easier to reason about, and more cost efficient and performant




