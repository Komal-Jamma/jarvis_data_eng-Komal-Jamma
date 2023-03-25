<<EOF
###### Question 1: The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values: facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

```sql
Insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    Values(9, 'Spa', 20, 30, 100000, 800);
```

###### Questions 2: We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.

```sql
Update cd.facilities
   Set initialoutlay = 10000
   Where facid = 1;
```

###### Questions 3: As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this?

```sql
Delete from cd.bookings;  
```

###### Questions 4: We want to remove member 37, who has never made a booking, from our database. How can we achieve that?

```sql
Delete from cd.members
    Where memid = 37;
```

###### Questions 5: Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant. Use the following values for everything else:

Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

```sql
INSERT INTO cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    SELECT (SELECT max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800;
```

###### Questions 6: We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.

```sql
Update cd.facilities fac
    Set
        membercost = (select membercost * 1.1 from cd.facilities where facid = 0),
        guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0)
    Where fac.facid = 1; 
```

###### Questions 7: How can you produce a list of facilities, with each labelled as 'cheap' or 'expensive' depending on if their monthly maintenance cost is more than $100? Return the name and monthly maintenance of the facilities in question.

```sql
select name, 
	case when (monthlymaintenance > 100) then
		'expensive'
	else
		'cheap'
	end as cost
	from cd.facilities;
```

###### Questions 8: You, for some reason, want a combined list of all surnames and all facility names. Yes, this is a contrived example :-). Produce that list!

```sql
SELECT surname from cd.members
UNION
SELECT name from cd.facilities;
```

###### Questions 9:How can you produce a list of the start times for bookings by members named 'David Farrell'?

```sql
Select bk.starttime from cd.bookings bk
   inner join cd.members mb
   on mb.memid = bk.memid
where
   mb.firstname = 'David' and
   mb.surname = 'Farrell';
```

###### Questions 10: How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.

```sql
Select bk.starttime as start, fc.name as name 
From cd.facilities fc
   inner join cd.bookings bk
   on fc.facid = bk.facid
Where 
   fc.name in('Tennis Court 2', 'Tennis Court 1') and
   bk.starttime >= '2012-09-21'and
   bk.starttime< '2012-09-22'
Order by bk.starttime;
```

###### Questions 11: How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).

```sql
Select mem.firstname as memfname, mem.surname as memsname, rec.firstname as recfname, rec.surname as recsname
From cd.members mem
left outer join cd.members rec
on rec.memid=mem.recommendedby
Order by memsname, memfname;
```

###### Questions 12: How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).

```sql
Select rec.firstname as firstname, rec.surname as surname
From cd.members mem
inner join cd.members rec
on rec.memid=mem.recommendedby
Order by surname, firstname;
```

###### Questions 13: How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.

```sql
Select distinct mems.firstname || ' ' ||  mems.surname as member,
(Select recs.firstname || ' ' || recs.surname as recommender 
	From cd.members recs 
	Where recs.memid = mems.recommendedby
)
From 
	cd.members mems
Order by member; 
```

###### Questions 14: Produce a count of the number of recommendations each member has made. Order by member ID.

```sql
select recommendedby, count(*) 
	from cd.members
	where recommendedby is not null
	group by recommendedby
order by recommendedby;   
```

###### Questions 15: Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.

```sql
select facid, sum(slots) as "Total Slots"
	from cd.bookings
	group by facid
order by facid;  
```

###### Questions 16: Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.

```sql
Select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
	From cd.bookings
	Where extract(year from starttime) = 2012
	Group by facid, month
Order by facid, month; 
```

###### Questions 17: Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.

```sql
Select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
	From cd.bookings
	Where extract(year from starttime) = 2012
	Group by facid, month
Order by facid, month; 
```

###### Questions 18: Find the total number of members (including guests) who have made at least one booking.

```sql
select count(distinct memid) from cd.bookings
```

###### Questions 19: Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.

```sql
Select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
	From cd.bookings
	Where extract(year from starttime) = 2012
	Group by facid, month
Order by facid, month; 
```

###### Questions 20: Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.

```sql
Select count(*) over(), firstname, surname
	From cd.members
Order by joindate  
```

###### Questions 21: Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.

```sql
select row_number() over(order by joindate), firstname, surname
	from cd.members
order by joindate  
```

###### Questions 22: Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.

```sql
select facid, total from (
	select facid, sum(slots) total, rank() over (order by sum(slots) desc) rank
        	from cd.bookings
		group by facid
	) as ranked
	where rank = 1 
```

###### Questions 23: Output the names of all members, formatted as 'Surname, Firstname'

```sql
Select surname || ', ' || firstname as name 
From cd.members   
```

###### Questions 24: Perform a case-insensitive search to find all facilities whose name begins with 'tennis'. Retrieve all columns.

```sql
Select * from cd.facilities 
Where upper(name) like 'TENNIS%';  
```

###### Questions 25: You've noticed that the club's member table has telephone numbers with very inconsistent formatting. You'd like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.

```sql
select memid, telephone from cd.members where telephone ~ '[()]'; 
```

###### Questions 26: You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet. Sort by the letter, and don't worry about printing out a letter if the count is 0.

```sql
Select substr (mems.surname,1,1) as letter, count(*) as count 
   From cd.members mems
   Group by letter
   Order by letter 
```


EOF