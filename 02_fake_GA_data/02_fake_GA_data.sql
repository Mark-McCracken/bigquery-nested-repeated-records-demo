CREATE or replace table `bq_nested_repeated_fields_demo.04_fake_GA_data` as
WITH
  sports AS (
  SELECT
    'Football' AS sport
  UNION ALL
  SELECT
    'Tennis' AS sport
  UNION ALL
  SELECT
    'Formula 1' AS sport
),
  leagues AS (
  SELECT
    'Football' AS sport,
    'Champions League' AS league
  UNION ALL
  SELECT
    'Football' AS sport,
    'Europa League' AS league
  UNION ALL
  SELECT
    'Football' AS sport,
    'Premier League' AS league
  UNION ALL
  SELECT
    'Tennis' AS sport,
    'World Cup' AS league
  UNION ALL
  SELECT
    'Tennis' AS sport,
    'Wimbledon' AS league
  UNION ALL
  SELECT
    'Tennis' AS sport,
    'Australian Open' AS league
  UNION ALL
  SELECT
    'Formula 1' AS sport,
    'Formula 1' AS league
  UNION ALL
  SELECT
    'Formula 1' AS sport,
    'Formula 2' AS league
  UNION ALL
  SELECT
    'Formula 1' AS sport,
    'Formula 3' AS league
  UNION ALL
  SELECT
    'Formula 1' AS sport,
    'Formula E' AS league
  UNION ALL
  SELECT
    'Formula 1' AS sport,
    'Formula W' AS league
),
  sessions AS (
  SELECT
    *,
    row_number() over (partition by fullVisitorId) as visitNumber
  from (
    select
      CONCAT('visitor', CAST(FLOOR(50 * RAND()) AS STRING)) AS fullVisitorId,
      TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL cast(FLOOR(1000 * RAND()) as int64) SECOND) AS sessionStartTime,
      FLOOR(1000000 * RAND()) AS visitId,
      TRUE AS isSessionStart,
      TRUE AS isSessionEnd
    FROM
      UNNEST(GENERATE_ARRAY(1, 100)) AS unused
  )
),
  hits AS (
  SELECT
    fullVisitorId,
    sessionStartTime,
    visitId,
    visitNumber,
    isSessionStart,
    isSessionEnd,
    row_number() over() as hitNumber,
    TIMESTAMP_ADD(sessionStartTime, INTERVAL cast(FLOOR(1800 * RAND()) as int64) SECOND) AS hitTimestamp,
    CASE FLOOR(10 * RAND())
      WHEN 0 THEN 'PAGE'
      WHEN 1 THEN 'EVENT'
      WHEN 2 THEN 'TRANSACTION'
      ELSE 'PAGE'
    END AS hitType,

    STRUCT(
      CONCAT('/pagecategory', CAST(FLOOR(10 * RAND()) AS STRING)) AS pagePath,
      CONCAT('PageTitle', CAST(FLOOR(10 * RAND()) AS STRING)) AS pageTitle,
      CONCAT('PageHostname', CAST(FLOOR(10 * RAND()) AS STRING)) AS pageHostname,
      CONCAT('PageSearchKeyword', CAST(FLOOR(10 * RAND()) AS STRING)) AS pageSearchKeyword,
      FLOOR(100 * RAND()) AS pageLoadTime,
      FLOOR(100 * RAND()) AS serverResponseTime,
      FLOOR(100 * RAND()) AS pageDownloadTime,
      FLOOR(100 * RAND()) AS pageRenderTime
    ) as page,
  CASE FLOOR(10 * RAND())
    WHEN 0 THEN
      STRUCT(
        CONCAT('/eventcategory', CAST(FLOOR(10 * RAND()) AS STRING)) AS eventCategory,
        CONCAT('EventAction', CAST(FLOOR(10 * RAND()) AS STRING)) AS eventAction,
        CONCAT('EventLabel', CAST(FLOOR(10 * RAND()) AS STRING)) AS eventLabel,
        FLOOR(100 * RAND()) AS eventValue
      )
    ELSE
      NULL
  END AS event,
STRUCT(
  CONCAT('/screenview/', CAST(FLOOR(10 * RAND()) AS STRING)) AS screenName
) AS appInfo,
[
  struct('sport' as name, IF(sports.sport = 'Football', 'Football', IF(sports.sport = 'Tennis', 'Tennis', 'Formula 1')) AS value),
  struct('league', league),
  struct('match', CONCAT('Match-', CAST(FLOOR(10 * RAND()) AS STRING))),
  struct('matchState', CASE FLOOR(10 * RAND())
    WHEN 0 THEN 'Playing'
    WHEN 1 THEN 'Halftime'
    WHEN 2 THEN 'Fulltime'
    ELSE 'Not Started'
  END),
  struct('screen', case cast(FLOOR(6 * RAND()) as int64) when 0 then 'Home Screen' when 1 then 'league view' when 2 then 'Match Overview' when 3 then 'Team Details' when 4 then 'Live Stream' else 'comments' end)
] AS customDimensions
FROM
sessions
CROSS JOIN
sports
JOIN
leagues
ON
sports.sport = leagues.sport
)
SELECT
fullVisitorId,
sessionStartTime,
visitId,
visitNumber,
ARRAY_AGG(
STRUCT(
hitNumber,
hitType,
TIMESTAMP_ADD(sessionStartTime, INTERVAL cast((rand() * 1000) as int64) SECOND) AS hitTime,
page AS page,
event AS event,
appInfo AS appInfo,
customDimensions AS customDimensions
)
ORDER BY hitNumber ASC
) AS hits
FROM
hits
GROUP BY
fullVisitorId,
sessionStartTime,
visitId,
visitNumber
ORDER BY
fullVisitorId ASC,
visitNumber ASC,
visitId ASC