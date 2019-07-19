---
title: "Finding Longest Streak of Days With Postgresql"
date: 2019-06-08T00:36:08-04:00
tags: ["sql"]
draft: false
---

For the past few months Ive been working on a pomodoro web app to get some experience
with Go and VueJS. Ive slowly been adding stat related features, the most pomodoros
you completed in one day, line charts depicting your progress over the past few
weeks, etc.

Another quick stat I wanted to add was the longest streak of days a user completed a pomodoro,
This seemed like a common enough query, surely this isnt too much trouble in SQL right?
If you're reading this Im sure by now you've discovered that this is actually a pretty tricky
problem to tackle with SQL.

First lets look at my pomodoro table definition:

{{< highlight sql>}}
CREATE TABLE "pomodoro_sessions" (
    id BIGSERIAL PRIMARY KEY,
    user_id  INT REFERENCES users(id),
    duration INT NOT NULL,
    created_at TIMESTAMP NOT NULL
);
{{< /highlight >}}

Not too much going on here, to construct our longest streak query we only need `created_at`
and `user_id`.

From there you must make a key insight as to the nature of a streak of data, we must
identify some unique aspect of the data that makes up a streak.
What would happen if you assigned an index to each row of the streak, can you see a pattern?

Consider this example streak:

{{< highlight sql >}}

Index  Created_At
0      1/1/2019
1      1/2/2019
2      1/3/2019
3      1/4/2019

{{< /highlight >}}

The key insight is that if you substract the index number from the creation date, a streak
will all have the same creation date, as shown below:

{{< highlight sql >}}

Index  Created_At    Created_At - Index
0      1/1/2019      1/1/2019
1      1/2/2019      1/1/2019
2      1/3/2019      1/1/2019
3      1/4/2019      1/1/2019

{{< /highlight >}}

Using this insight, we can construct our SQL query. We will need to make use of the PostgreSQL
built in function `row_number()` to create our index numbers, and at the end use group by
to identify streaks of data whose created_at subtracted by their row number equal the same date.

The final SQL looks like this:

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

I hope this was helpful for other folks looking to do something similar.

Some resources that helped:
[10 sql tricks](https://jaxenter.com/10-sql-tricks-that-you-didnt-think-were-possible-125934.html)
