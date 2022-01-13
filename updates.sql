/*
The club is adding a new facility - a spa.
We need to add it into the facilities table.
Use the following values:

facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

add to table facilities:
facid: 9, name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800
*/
INSERT INTO cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    VALUES (9, 'Spa', 20, 30, 100000, 800);


/*
In the previous exercise, you learned how to add a facility. 
Now you're going to add multiple facilities in one command. Use the following values:

facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
facid: 10, Name: 'Squash Court 2', membercost: 3.5, guestcost: 17.5, initialoutlay: 5000, monthlymaintenance: 80.
*/
INSERT INTO cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance) VALUES
    (9, 'Spa', 20, 30, 100000, 800),
    (10, 'Squash Court 2', 3.5, 17.5, 5000, 80);


/*
Let's try adding the spa to the facilities table again. 
This time, though, we want to automatically generate the value for the next facid, 
rather than specifying it as a constant. Use the following values for everything else:

name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

insert into facilities:
    facid: next_value(select facid from facilities)
*/ 
INSERT INTO cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance) 
    VALUES ((SELECT max(facid) FROM cd.facilities) + 1, 'Spa', 20, 30, 100000, 800);


/*
We made a mistake when entering the data for the second tennis court.
The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.
*/
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE facid = 1;


/*
We want to increase the price of the tennis courts for both members and guests.
Update the costs to be 6 for members, and 30 for guests.

update facilities
set membercost = 6, guestcost = 30
where name contains 'tennis court';
*/
UPDATE cd.facilities
SET membercost = 6, guestcost = 30
WHERE name ILIKE '%tennis court%';


/*
We want to alter the price of the second tennis court so that it costs 10% more than the first one.
Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.

with tfac1 = (select membercost, guestcost from facilities where name = 'Tennis Court 1'):
    update facilities as tfac2:
        set tfac2.membercost, tfac2.guestcost = (tfac1.membercost * 110%, tfac1.guestcost * 110%)
        where tfac2.name = 'Tennis Court 2'
*/
UPDATE cd.facilities
SET (membercost, guestcost) =
    (SELECT membercost * 1.1, guestcost * 1.1
     FROM cd.facilities
     WHERE name = 'Tennis Court 1' )
WHERE name = 'Tennis Court 2';


/*
As part of a clearout of our database, we want to delete all bookings from the cd.bookings table.
How can we accomplish this?

delete all records from table bookings
*/
DELETE FROM cd.bookings;


/*
We want to remove member 37, who has never made a booking, from our database. How can we achieve that?
*/
DELETE FROM cd.members WHERE memid = 37;


/*
Delete all members who have not made a booking
*/
DELETE FROM cd.members
WHERE memid NOT IN (SELECT memid FROM cd.bookings);


/*
We want to know how many facilities exist - simply produce a total count
*/
SELECT count(*) FROM cd.facilities;


/* Produce a count of the number of facilities that have a cost to guests of 10 or more. */
select count(*) from cd.facilities where guestcost >= 10;


/* Produce a count of the number of recommendations each member has made. Order by member ID. */
SELECT recommendedby, count(*) AS COUNT
    FROM cd.members AS tmem
    WHERE recommendedby IS NOT NULL
    GROUP BY recommendedby
ORDER BY tmem.recommendedby;


/* Produce a list of the total number of slots booked per facility.
For now, just produce an output table consisting of facility id and slots, sorted by facility id.
*/
SELECT facid, sum(slots) AS "Total Slots"
    FROM cd.bookings
    GROUP BY facid
ORDER BY facid ;


/* Produce a list of the total number of slots booked per facility in the month of September 2012.
Produce an output table consisting of facility id and slots, sorted by the number of slots.*/
SELECT facid, sum(slots) AS "Total Slots"
    FROM cd.bookings
    WHERE to_char(starttime, 'YYYY-MM') = '2012-09'
    GROUP BY facid
ORDER BY "Total Slots" ;
