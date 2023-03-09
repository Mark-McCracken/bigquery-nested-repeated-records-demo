## Getting some help from ChatGPT

Nobody likes to start from scratch, so I got some help.

<code>markmccracken91@me.com</code>

<quote>create a big query table with an int field called user_id with possible values from 1 to 10, and a date field with possible values of the 10 most recent dates, field called activity_date, a string field called sport with possible values of "football", "tennis", "formula 1" and "rugby".
Create 50 records to go in this table, with multiple values for each user_id and date, and distinct values for sport
</quote>

<code>ChatGPT</code>

<quote>To create the table, you can use the following BigQuery SQL query:</quote>

```sql
CREATE TABLE my_table (
  user_id INT64,
  activity_date DATE,
  sport STRING
);
```

<quote>To insert 50 records with the specifications provided, you can use the following SQL query:</quote>

```sql
INSERT INTO my_table (user_id, activity_date, sport)
SELECT 
  MOD(ROW_NUMBER() OVER(), 10) + 1 AS user_id,
  DATE_SUB(CURRENT_DATE(), INTERVAL MOD(ROW_NUMBER() OVER(), 10) DAY) AS activity_date,
  CASE MOD(ROW_NUMBER() OVER(), 4)
    WHEN 0 THEN "football"
    WHEN 1 THEN "tennis"
    WHEN 2 THEN "formula 1"
    WHEN 3 THEN "rugby"
  END AS sport
FROM 
  UNNEST(GENERATE_ARRAY(1, 50)) AS row
```

<quote>This will insert 50 records into the my_table table, with each user_id having multiple records on distinct activity_date values and distinct sport values.
The ROW_NUMBER() function is used to generate unique values for each row, which are then used to determine the user_id, activity_date, and sport values using various calculations.
The GENERATE_ARRAY() function is used to generate an array of integers from 1 to 50, which is then unnested to generate 50 rows.</quote>

<hr>

## Comments

Not bad output, but the date generation isn't quite what I'm looking for, using the row number means progressive user ids come out with dates all clumped together, making each user look like they've only been active on one day.

It also doesn't ensure each record is distinct, but easy enough with some very small fixes.
