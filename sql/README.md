<< EOF
# Introduction



# SQL Quries

###### Table Setup (DDL)

1. Creating a table schema for cd.members

   Create table cd.members
   (
   memid integer not null,
   surname character varying(200) not null,
   firstname character varying(200) not null,
   address character varying(300) not null,
   zipcode integer not null,
   telephone character varying(20) not null,
   recommendedby integer,
   joindate timestamp not null,
   CONSTRAINT members_pk PRIMARY KEY (memid),
   CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
   REFERENCES cd.members(memid) ON DELETE SET NULL
   );

2. Creating a table schema for cd.bookings
   Create table cd.bookings
   (
   bookid integer not null,
   facid integer not null,
   memid integer not null,
   starttime timestamp not null,
   slots integer not null,
   CONSTRAINT bookings_pk PRIMARY KEY (bookid),
   CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
   CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
   );

3. Creating a table schema for cd.facilities
   Create table cd.facilities
   (
   facid integer not null,
   name character varying(100) not null,
   membercost numeric not null,
   guestcost numeric not null,
   initialoutlay numeric not null,
   monthlymaintenance numeric not null,
   CONSTRAINT facilities_pk PRIMARY KEY (facid)
   );

   
###### Question 1: Show all members 

```sql
SELECT *
FROM cd.members
```

###### Questions 2: 
The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values:

facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800..

```sql
INSERT INTO cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    values(9, 'Spa', 20, 30, 100000, 800);
```

###### Questions 3:
Question
Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant. Use the following values for everything else:

Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

```sql
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    select (select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800;
```

###### Questions 4:
We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.

```sql
UPDATE cd.facilities
    SET initialoutlay = 10000
    WHERE facid = 1; 
```
Explanation: The UPDATE statement is used to alter existing data. The WHERE clause specifies which record(s) that should be updated

###### Questions 5:
We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
```sql
update cd.facilities facs
    set
        membercost = (select membercost * 1.1 from cd.facilities where facid = 0),
        guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0)
    where facs.facid = 1; 
```

###### Questions 6:
As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this?
```sql
DELETE from cd.bookings;      
```

###### Questions 7:
We want to remove member 37, who has never made a booking, from our database. How can we achieve that?
```sql
delete from cd.members where memid = 37; 
```

###### Questions 8:
In our previous exercises, we deleted a specific member who had never made a booking. How can we make that more general, to delete all members who have never made a booking?
```sql
DELETE FROM cd.members WHERE memid NOT IN (SELECT memid FROM cd.bookings);   
```

###### Questions 9:
How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
```sql
SELECT facid, name, membercost, monthlymaintenance 
	FROM cd.facilities 
	WHERE
		membercost > 0 and 
		(membercost < monthlymaintenance/50.0); 
```

###### Questions 10:
How can you produce a list of all facilities with the word 'Tennis' in their name?
```sql
SELECT * FROM cd.facilities 
WHERE 
name like '%Tennis%';  
```

###### Questions 11:
How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.
```sql
SELECT * FROM cd.facilities
WHERE 
facid in(1,5);
```

###### Questions 12:
How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question.
```sql
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE
joindate >= '2012-09-01';
```

###### Questions 13:
How can you produce an ordered list of the first 10 surnames in the members table? The list must not contain duplicates.
```sql
SELECT DISTINCT surname 
FROM cd.members
ORDER BY surname
limit 10;
```

###### Questions 14:
You, for some reason, want a combined list of all surnames and all facility names. Yes, this is a contrived example :-). Produce that list!
```sql
SELECT surname from cd.members
UNION
select name from cd.facilities;
```

###### Questions 15:
You'd like to get the signup date of your last member. How can you retrieve this information?
```sql
SELECT MAX(joindate) AS latest_join FROM cd.members
```

###### Questions 16:
You'd like to get the first and last name of the last member(s) who signed up - not just the date. How can you do that?
```sql
SELECT firstname, surname, joindate FROM cd.members
WHERE joindate = (SELECT MAX(joindate) from cd.members);
```

###### Questions 17:
How can you produce a list of the start times for bookings by members named 'David Farrell'?
```sql
SELECT bk.starttime from cd.bookings bk
inner join cd.members mb
on mb.memid = bk.memid
WHERE
mb.firstname = 'David' AND
mb.surname = 'Farrell';
```

###### Questions 18:
How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
```sql
select bk.starttime as start, fc.name as name 
from cd.facilities fc
inner join cd.bookings bk
on fc.facid = bk.facid
where 
fc.name in('Tennis Court 2', 'Tennis Court 1') and
bk.starttime >= '2012-09-21'and
bk.starttime< '2012-09-22'
order by bk.starttime;
```

###### Questions 19:
How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
```sql
Select rec.firstname as firstname, rec.surname as surname
from cd.members mem
inner join cd.members rec
on rec.memid=mem.recommendedby
order by surname, firstname;
```

###### Questions 20:
How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).
```sql
Select mem.firstname as memfname, mem.surname as memsname, rec.firstname as recfname, rec.surname as recsname
From cd.members mem
Left outer join cd.members rec
ON rec.memid=mem.recommendedby
Order by memsname, memfname;
```

###### Questions 21:
Produce a count of the number of recommendations each member has made. Order by member ID.
```sql
Select recommendedby, count(*) 
From cd.members
Where recommendedby is not null
Group by recommendedby
Order by recommendedby; 
```

###### Questions 22:
Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.
```sql
Select facid, sum(slots) as "Total Slots"
From cd.bookings
Group by facid
Order by facid;  
```

###### Questions 23:
Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.
```sql
Select facid, sum(slots) as "Total Slots"
From cd.bookings
Where
	starttime >= '2012-09-01'
	and starttime < '2012-10-01'
Group by facid
Order by sum(slots);
```

###### Questions 25:
Find the total number of members (including guests) who have made at least one booking.
```sql
select count(distinct memid) from cd.bookings   
```

###### Questions 26:
Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
```sql
Select mem.surname, mem.firstname, mem.memid, min(bks.starttime) as starttime
From cd.bookings bk
inner join cd.members mem on
	mem.memid = bk.memid
where starttime >= '2012-09-01'
group by mem.surname, mem.firstname, mem.memid
order by mem.memid;
```

###### Questions 27:
Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.
```sql
Select (select count(*) from cd.members) as count, firstname, surname
From cd.members
Order by joindate;
```

###### Questions 28:

```sql
Select row_number() over(order by joindate), firstname, surname
From cd.members
Order by joindate;
```

###### Questions 29:
Output the names of all members, formatted as 'Surname, Firstname'
```sql
select surname || ', ' || firstname as name from cd.members;
```

###### Questions 30:
You've noticed that the club's member table has telephone numbers with very inconsistent formatting. You'd like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.
```sql
select memid, telephone from cd.members where telephone ~ '[()]';   
```

###### Questions 31:

```sql
Select substr (mem.surname,1,1) as letter, count(*) as count 
From cd.members mem
Group by letter
Order by letter;
```


EOF

