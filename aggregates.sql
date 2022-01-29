/*
Produce a list of the total number of slots booked per facility per month in the year of 2012.
Produce an output table consisting of facility id and slots, sorted by the id and month.
*/
SELECT facid, extract(MONTH FROM starttime) AS month, sum(slots) AS "Total Slots"
    FROM cd.bookings
    WHERE extract(YEAR FROM starttime) = 2012
    GROUP BY facid, MONTH
    ORDER BY facid, MONTH;


/*
Produce a list of facilities with more than 1000 slots booked.
Produce an output table consisting of facility id and slots, sorted by facility id.
*/
SELECT facid, SUM(slots) AS "Total Slots"
    FROM cd.bookings
    GROUP BY facid
    HAVING SUM(slots) > 1000
    ORDER BY facid;


/*
Produce a list of facilities along with their total revenue.
The output table should consist of facility name and revenue, sorted by revenue.
Remember that there's a different cost for guests and members!

revenue = sum(slots * cost)
cost(member) = guestcost if is_guest(member) else membercost
*/

WITH bookings AS
    (SELECT name,
            CASE
                WHEN bookid IS NULL THEN 0
                WHEN memid = 0 THEN guestcost
                ELSE membercost
            END AS cost,
            CASE
                WHEN bookid IS NULL THEN 0
                ELSE slots
            END AS slots
     FROM cd.facilities
     LEFT JOIN cd.bookings USING (facid))
SELECT name, sum(cost * slots) AS revenue
FROM bookings
GROUP BY name
ORDER BY revenue;


/*
Produce a list of facilities with a total revenue less than 1000.
Produce an output table consisting of facility name and revenue, sorted by revenue.
Remember that there's a different cost for guests and members!

revenue = sum(slots * cost)
cost(member) = guestcost if is_guest(member) else membercost
*/ 
WITH bookings AS
    (SELECT name,
            CASE
                WHEN bookid IS NULL THEN 0
                WHEN memid = 0 THEN guestcost
                ELSE membercost
            END AS cost,
            CASE
                WHEN bookid IS NULL THEN 0
                ELSE slots
            END AS slots
     FROM cd.facilities
     LEFT JOIN cd.bookings USING (facid))
SELECT name, sum(cost * slots) AS revenue
FROM bookings
GROUP BY name
HAVING sum(cost * slots) < 1000
ORDER BY revenue;


/*
Output the facility id that has the highest number of slots booked.
For bonus points, try a version without a LIMIT clause.
This version will probably look messy!

number of slots = sum(slots grouped by facility)
*/
WITH allslots AS
    (SELECT sum(slots) AS slots
     FROM cd.bookings
     GROUP BY facid)
SELECT facid, sum(slots) AS slots
FROM cd.bookings
GROUP BY facid
HAVING sum(slots) = (SELECT max(slots) FROM allslots);


/*
Produce a list of the total number of slots booked per facility per month in the year of 2012.
In this version, include output rows containing totals for all months per facility,
and a total for all months for all facilities.

The output table should consist of facility id, month and slots, sorted by the id and month.
When calculating the aggregated values for all months and all facids,
return null values in the month and facid columns.

facid   month   slots
1       7       2
1       8       3
1               5           --> 2+3
2       7       1
2       9       3
2               4           --> 1+3
                9           --> 5+4
*/
SELECT facid, EXTRACT (MONTH FROM starttime) AS month, SUM(slots) AS slots
FROM cd.bookings
WHERE EXTRACT (YEAR FROM starttime) = 2012
GROUP BY ROLLUP(facid, month)
ORDER BY facid, MONTH;


/*
Produce a list of the total number of hours booked per facility, remembering that a slot lasts half an hour.
The output table should consist of the facility id, name, and hours booked, sorted by facility id.
Try formatting the hours to two decimal places.

facid   name        Total Hours     --> sum(slots) * (1/2 hour)
1       Tennis      2
2       Badminton   3
*/
SELECT facid, name, ROUND(SUM(slots) / 2.0, 2) AS "Total Hours"
FROM cd.facilities
INNER JOIN cd.bookings USING (facid)
GROUP BY facid, name
ORDER BY facid, name;


/*
Produce a list of each member name, id, and their first booking after September 1st 2012.
Order by member ID.
*/
WITH bookings AS
    (SELECT surname, firstname, memid,
         (SELECT min(starttime)
          FROM cd.bookings
          WHERE memid = tmbr.memid
              AND starttime > cast('2012-09-01' AS date) ) AS starttime
     FROM cd.members AS tmbr)
SELECT surname, firstname, memid, starttime
FROM bookings
WHERE starttime IS NOT NULL
ORDER BY memid;