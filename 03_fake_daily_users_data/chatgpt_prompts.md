## ChatGPT prompts

<code>markmccracken91@me.com</code>

<quote>I have a big query table with the following schema:</quote>

```sql
create or replace table `bq_nested_repeated_fields_demo.daily_users` (
	date DATE not null,
	fullVisitorId string,
	platform string not null options(description="One of Desktop, Mobile, Android, iOS"),
	browser STRUCT<
		name string,
		version string
	>,
	operatingSystem STRUCT<
		name string,
		version string
	>,
	device STRUCT<
		category string,
		make string,
		model string
	>,
	isLikelyBot boolean,
	appVersion string,
	mainOrientation string,
	orientations ARRAY<STRING>,
	mainCountryName string options(description="Defined by the country that contributed the longest total hit duration"),
	geo struct<
		mainContinent string,
		mainCountry string options(description="Defined by the country that has the most days as the users's main country. If several countries have equal days, most recent is chosen"),
		mainRegion string options(description="Defined by the region that has the most days as the user's main region, but only regions in the user's mainCountry are considered."),
		mainMetro string options(description="Defined by the metro that has the most days as the user's main metro, but only metros in the user's mainGeoRegion are considered."),
		mainCity string options(description="Defined by the city that has the most days as the user's main city, but only cities in the user's mainGeoMetro are considered."),
		countryNames array<string>
	>,
	isFirstVisit STRUCT<
		ever BOOLEAN,
		thisWeek BOOLEAN,
		thisMonth BOOLEAN,
		since date
	>,
	total STRUCT<
		hits int64,
		sessions int64 options(description="Total number of sessions, including sessions that don't count as a visit"),
		pageViews int64,
		secondsOnSite int64
	>,
	views array<struct<
    sport string,
    sportTotal STRUCT<
      hits int64,
      sessions int64,
      pageViews int64,
      secondsOnSport int64
    >,
    competitions array<struct<
      competition_name string,
      competitionTotal struct<
        hits int64,
        sessions int64,
        pageViews int64,
        secondsOnCompetition int64
      >,
      sportingEvents array<struct<
        country string,
        homeTeam string,
        awayTeam string,
        sportingEventTotal struct <
          hits int64,
          sessions int64,
          pageViews int64,
          secondsOnEvent int64
        >,
        sportingEventStateDetails array<struct<
          state string,
          stateTotal struct<
            hits int64,
            sessions int64,
            pageViews int64,
            secondsOnEventState int64
          >,
          screenDetails array<struct<
            screen string,
            screenTotal struct<
              hits int64,
              sessions int64,
              pageViews int64,
              secondsOnScreenView int64
            >
          >>
        >>
      >>
    >>
  >>
)
OPTIONS (
	description="A more aggregated overview of each visitor's behaviour per day, aggregated from sessions, which can have multiple in one day."
)
```

<quote>Can you generate a row of data to insert into the table?</quote>

<code>ChatGPT</code>

<quote>Sure! Here's an example row of data that you could insert into the daily_users table:</quote>

```sql
INSERT INTO `bq_nested_repeated_fields_demo.daily_users`
VALUES (
    DATE '2022-01-01',
    '123456789',
    'Desktop',
    STRUCT('Chrome', '95.0.4638.69'),
    STRUCT('Windows', '10'),
    STRUCT('desktop', 'HP', 'Elitebook'),
    FALSE,
    '1.0.0',
    'landscape',
    ['portrait', 'landscape'],
    'United States',
    STRUCT(FALSE, TRUE, TRUE, DATE '2022-01-01'),
    STRUCT(10, 3, 20, 180),
    ARRAY[
      STRUCT(
        'Basketball',
        STRUCT(2, 1, 10, 60),
        ARRAY[
          STRUCT(
            'NBA',
            STRUCT(1, 1, 5, 30),
            ARRAY[
              STRUCT(
                'USA',
                'Lakers',
                'Nets',
                STRUCT(1, 1, 5, 30),
                ARRAY[
                  STRUCT(
                    'in_game',
                    STRUCT(1, 1, 5, 30),
                    ARRAY[STRUCT('play_by_play', STRUCT(1, 1, 5, 30))]
                  )
                ]
              )
            ]
          ),
          STRUCT(
            'EuroLeague',
            STRUCT(1, 1, 5, 30),
            ARRAY[
              STRUCT(
                'Spain',
                'Real Madrid',
                'Barcelona',
                STRUCT(1, 1, 5, 30),
                ARRAY[
                  STRUCT(
                    'in_game',
                    STRUCT(1, 1, 5, 30),
                    ARRAY[STRUCT('play_by_play', STRUCT(1, 1, 5, 30))]
                  )
                ]
              )
            ]
          )
        ]
      )
    ]
);
```

<quote>Note that this is just an example row of data and the actual values you would insert into the table would depend on your specific use case.</quote>

<hr>

## Comments

This was more challenging, because of the complexity of the schema.

Sometimes it forgot to include a couple of fields, which was easy to correct itself when prompted.

However, the big issue here was the restriction on the size of the output, and not being able to continue the output.

It would happily promise to give me 20 rows, but then terminate after the first row, but would not continue it's output with a prompt.

When I asked it to generate a single row with multiple sports and multiple match states or screen views, then the row became too large to come in a single output.

I did however use it as a starting point.

