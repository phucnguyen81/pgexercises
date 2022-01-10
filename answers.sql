-- How can you retrieve all the information from the cd.facilities table?
-- select all records from table cd.facilities
SELECT * FROM cd.facilities;


-- You want to print out a list of all of the facilities and their cost to members.
-- How would you retrieve a list of only facility names and costs?
-- select name and member cost from table facility
SELECT name, membercost FROM cd.facilities;


-- How can you produce a list of facilities that charge a fee to members?
SELECT * FROM cd.facilities WHERE membercost > 0;


-- How can you produce a list of facilities that charge a fee to members, 
-- and that fee is less than 1/50th of the monthly maintenance cost? 
-- Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
SELECT facid, name, membercost, monthlymaintenance FROM cd.facilities
where (
	membercost > 0
	and membercost * 50 < monthlymaintenance
);


-- How can you produce a list of all facilities with the word 'Tennis' in their name?
SELECT * FROM cd.facilities WHERE name LIKE '%Tennis%';


-- How can you retrieve the details of facilities with ID 1 and 5? 
-- Try to do it without using the OR operator.
SELECT * FROM cd.facilities WHERE facid IN (1,5);


/**
How can you produce a list of facilities,
with each labelled as 'cheap' or 'expensive' depending on
if their monthly maintenance cost is more than $100?
Return the name and monthly maintenance of the facilities in question.

select name, cost from facilities
where cost =
    'expensive' if monthlymaintenance > 100 else 'cheap'
*/
SELECT name,
       CASE
           WHEN monthlymaintenance > 100 THEN 'expensive'
           ELSE 'cheap'
       END AS cost
FROM cd.facilities;


/*
How can you produce a list of members who joined after the start of September 2012?
Return the memid, surname, firstname, and joindate of the members in question.

select memid, surname, firstname, joindate
from members
where joindate is on or after 2012-09-01
*/
SELECT memid,
       surname,
       firstname,
       joindate
FROM cd.members
WHERE joindate >= cast('2012-09-01' AS date);


/*
How can you produce an ordered list of the first 10 surnames in the members table?
The list must not contain duplicates.

select surname from table members
make surname unique
sort by surname
take the first 10 rows
*/
select distinct surname
from cd.members
order by surname
limit 10;


/*
For some reason, want a combined list of all surnames and all facility names.

select surname from members
union
select name from facilities
*/
select surname from cd.members
union
select name as surname from cd.facilities;


/*
You'd like to get the signup date of your last member. How can you retrieve this information?

last member = member with the most recent joindate

select max(signup date) from table members
*/
select max(joindate) as latest from cd.members;


/*
You'd like to get the first and last name of the last member(s) who signed up - not just the date.
How can you do that?

select first_name, last_name, join_date from members
where join_date = max(join_date in members)
*/
SELECT firstname, surname, joindate
FROM cd.members
WHERE joindate = (
    SELECT max(joindate) FROM cd.members
);


/*
How can you produce a list of the start times for bookings by members named 'David Farrell'?

select startime
from bookings, members joined on memid
where firstname = 'David' and surname = 'Farrell'
*/
select b.starttime
from cd.bookings as b
inner join cd.members as m
using (memid)
where (
    m.firstname = 'David' and m.surname = 'Farrell'
);


/*
How can you produce a list of the start times for bookings for tennis courts,
for the date '2012-09-21'?
Return a list of start time and facility name pairings, ordered by the time.

select booking.start_time
from bookings, facilities
where date(booking.start_time) = date('2012-09-21')
and facility.name contains 'tennis court'
sorted by booking.start_time
;
*/
SELECT bks.starttime as start, fcs.name as name
FROM cd.bookings AS bks
INNER JOIN cd.facilities AS fcs USING (facid)
WHERE (cast(bks.starttime AS date) = cast('2012-09-21' AS date)
       AND fcs.name ILIKE '%tennis court%')
ORDER BY bks.starttime;


/*
How can you output a list of all members who have recommended another member?
Ensure that:
- there are no duplicates in the list, 
- results are ordered by (surname, firstname).

recommend another member = memid is in recommendedby values
no duplicates = distinct
ordered by surname, firstname
*/
select distinct firstname, surname
from cd.members
where memid in (select recommendedby from cd.members)
order by surname, firstname;


/*
How can you output a list of all members,
including the individual who recommended them (if any)?
Ensure that results are ordered by (surname, firstname).

select
from member
join with recommender if any
where
    recommender.memid = member.recommendedby
    ordered by member.surname, member.firstname
*/
SELECT mems.firstname AS memfname,
       mems.surname AS memsname,
       recs.firstname AS recfname,
       recs.surname AS recsname
FROM cd.members AS mems
LEFT JOIN cd.members AS recs ON (mems.recommendedby = recs.memid)
ORDER BY mems.surname,
         mems.firstname ;


/*
How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member formatted as a single column.
Ensure no duplicate data, and order by the member name followed by the facility name.

Requirements:
- the member has used a tennis court DONE
- court name + member name as a column DONE
- no duplicate data DONE
- order by member name, facility name
*/
SELECT DISTINCT
    CONCAT(mbr.firstname, ' ', mbr.surname) AS member, 
    fac.name AS facility
FROM cd.members AS mbr
INNER JOIN cd.bookings AS bkg USING (memid)
INNER JOIN cd.facilities AS fac USING (facid)
WHERE fac.name ILIKE '%tennis court%'
ORDER BY member, facility ;


/*
How can you produce a list of bookings on the day of 2012-09-14
which will cost the member (or guest) more than $30?
Remember that guests have different costs to members (the listed costs are per half-hour 'slot'),
and the guest user is always ID 0.
Include in your output the name of the facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries.

select *
from bookings
where starttime = 2012-09-14
that cost(booking) > 30

How to calculate cost(booking) ?
cost(booking) = slots * (guestcost if memid = 0 else membercost)
*/
SELECT concat(mbr.firstname, ' ', mbr.surname) AS member, fac.name AS facility,
       CASE
           WHEN bkg.memid = 0 THEN bkg.slots * fac.guestcost
           ELSE bkg.slots * fac.membercost
       END AS cost
FROM cd.bookings AS bkg
INNER JOIN cd.facilities AS fac USING (facid)
INNER JOIN cd.members AS mbr USING (memid)
WHERE CAST(bkg.starttime AS date) = CAST('2012-09-14' AS date)
    AND (CASE
             WHEN bkg.memid = 0 THEN bkg.slots * fac.guestcost
             ELSE bkg.slots * fac.membercost
         END) > 30
ORDER BY cost DESC;


/*
How can you output a list of all members,
including the individual who recommended them (if any),
without using any joins?

Ensure that there are no duplicates in the list,
and that each firstname + surname pairing is formatted as a column and ordered.

select member_name, (
    select member_name
    from members as recommender
    where recommender.memid = member.memid
)
from members as member;
*/
SELECT DISTINCT concat(mbr.firstname, ' ', mbr.surname) AS member,
    (SELECT concat(rec.firstname, ' ', rec.surname) AS recommender
     FROM cd.members AS rec
     WHERE rec.memid = mbr.recommendedby )
FROM cd.members AS mbr
ORDER BY member;


/*
The Produce a list of costly bookings exercise contained some messy logic: 
we had to calculate the booking cost in both the WHERE clause and the CASE statement.
Try to simplify this calculation using subqueries. For reference, the question was:

How can you produce a list of bookings on the day of 2012-09-14
which will cost the member (or guest) more than $30? 
Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), 
and the guest user is always ID 0. 
Include in your output the name of the facility, the name of the member formatted as a single column, and the cost.
Order by descending cost.
*/
SELECT member, facility, cost
FROM
    (SELECT concat(mbr.firstname, ' ', mbr.surname) AS member, fac.name AS facility,
            CASE
                WHEN bkg.memid = 0 THEN bkg.slots * fac.guestcost
                ELSE bkg.slots * fac.membercost
            END AS cost
     FROM cd.bookings AS bkg
     INNER JOIN cd.facilities AS fac USING (facid)
     INNER JOIN cd.members AS mbr USING (memid)
     WHERE cast(bkg.starttime AS date) = cast('2012-09-14' AS date)
     ORDER BY cost DESC) AS booking_cost
WHERE cost > 30;