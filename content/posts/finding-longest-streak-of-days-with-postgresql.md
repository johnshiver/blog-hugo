---
title: "Finding the Longest Streak of Days With Postgresql"
date: 2019-06-08T00:36:08-04:00
tags: ["sql", "tutorial"]
draft: false
---

For the past few months Ive been working on a pomodoro web app to get some experience
with Go and VueJS. Ive slowly been adding stat related features, the most pomodoros
you completed in one day, line charts depicting your progress over the past few
weeks, etc.

Another quick stat I wanted to add was the longest consecutive streak of days in which a given
user completed at least one pomodoro. This seemed like a common enough query, surely this isnt too
much trouble in SQL right? If you are reading this article then you probably already know
this is a tricky problem to tackle with SQL.

To begin, take a look at my pomodoro table definition:

{{< highlight sql>}}
CREATE TABLE "pomodoro_sessions" (
    id BIGSERIAL PRIMARY KEY,
    user_id  INT REFERENCES users(id),
    duration INT NOT NULL,
    created_at TIMESTAMP NOT NULL
);
{{< /highlight >}}

Not too much going on here, to construct our longest streak query we only need `created_at`
and `user_id`. Sadly this is where the easy part ends. From here we must identify some unique
aspect of the data that makes up a consecutive streak.

What would happen if you assigned an index to each row of the streak, can you see a pattern?

Consider this example data which includes streak:

{{< highlight sql >}}

Index  Created_At
0      1/1/2019
1      1/2/2019
2      1/3/2019
3      1/4/2019
4      1/6/2019

{{< /highlight >}}

The key insight is that if you substract the index number from the creation date a streak
will share the same creation date, as shown below:

{{< highlight sql >}}

Index  Created_At    Created_At - Index
0      1/1/2019      1/1/2019
1      1/2/2019      1/1/2019
2      1/3/2019      1/1/2019
3      1/4/2019      1/1/2019
4      1/6/2019      1/2/2019

{{< /highlight >}}

Using this insight we can construct our SQL query. To map `index` to `created_at` we need to make use
of the PostgreSQL window function [row_number()](https://www.postgresql.org/docs/11/functions-window.html).
After that its a matter of subtracting `created_at` by its row_number `index` and grouping the matches together.

Here is the SQL mapping `row_number()` to `created_date`:

{{< highlight sql>}}

 WITH pomo_dates AS (
 SELECT DISTINCT created_at::date created_date
 FROM pomodoro_sessions
 WHERE user_id=$1
 ),
 pomo_date_groups AS (
 SELECT
   row_number() OVER (ORDER BY created_date),
   created_date,
   created_date::DATE - CAST(row_number() OVER (ORDER BY created_date) as INT) AS grp
 FROM pomo_dates
   )
 SELECT
   *
 FROM pomo_date_groups;

{{< /highlight >}}


The output of which might look like:

{{< highlight sql>}}
+--------------+----------------+------------+
|   row_number | created_date   | grp        |
|--------------+----------------+------------|
|            1 | 2019-03-24     | 2019-03-23 |
|            2 | 2019-03-25     | 2019-03-23 |
|            3 | 2019-03-26     | 2019-03-23 |
|            4 | 2019-03-27     | 2019-03-23 |
|            5 | 2019-04-01     | 2019-03-27 |
|            6 | 2019-04-02     | 2019-03-27 |
|            7 | 2019-04-03     | 2019-03-27 |
|            8 | 2019-04-08     | 2019-03-31 |
|            9 | 2019-04-09     | 2019-03-31 |
|           10 | 2019-04-12     | 2019-04-02 |
|           11 | 2019-04-16     | 2019-04-05 |
+--------------+----------------+------------+
{{< /highlight >}}


Here is the final SQL statement, grouping the matches:

{{< highlight sql>}}

 WITH pomo_dates AS (
 SELECT DISTINCT created_at::date created_date
 FROM pomodoro_sessions
 WHERE user_id=$1
 ),
 pomo_date_groups AS (
 SELECT
   created_date,
   created_date::DATE - CAST(row_number() OVER (ORDER BY created_date) as INT) AS grp
 FROM pomo_dates
   )
 SELECT
   max(created_date) - min(created_date) + 1 AS length
 FROM pomo_date_groups
 GROUP BY grp
 ORDER BY length DESC
 LIMIT 1

{{< /highlight >}}


I hope this was helpful, if you have any questions
leave a comment below! The SQL and the rest of the source code lives
[here.](https://www.github.com/johnshiver/pomodoro/)

#### References

 * [10 sql tricks](https://jaxenter.com/10-sql-tricks-that-you-didnt-think-were-possible-125934.html)

 * [Practical row_number examples](http://www.postgresqltutorial.com/postgresql-row_number/)
