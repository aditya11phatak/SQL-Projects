---Basic Queries---
--1.Count the number of passengers
select count(*) as NO_of_Passengers
from train
	
--2.Find the number of survivors
select count(*) as No_of_survivors
from train 
where survived = 1

--3.Find the number of passengers by class
select Pclass,count(*) as Passengers_by_class,count( Passengers_by_class)
from train
group by Pclass

--4.Calculate the average fare paid by passengers
select round(avg(fare),2) as Avg_fare_paid
from train

--5.Find the number of male and female passengers
select sex,count(*)
from train
group by sex


---Intermediate Queries---
--1.Find the youngest and oldest passengers
select min(age) as youngest_passengers,max(age) as oldest_passengers
from train

--2.Calculate the survival rate by class
select pclass,round(avg(survived),2) as survival_rate
from train
group by pclass

--3.List passengers who paid more than the average fare
select name as Paid_More
from train
where fare > (select avg(fare) as avg_fare
from train)

--4.Find the number of passengers who embarked from each port
select embarked,count(*) as Embarked_count
from train 
group by embarked

--5.Find the average age of survivors and non-survivors
select survived,round(avg(age)) as Avg_age
from train
group by survived


---Advanced Queries---
--1.Calculate the survival rate for different age groups
select 
   case
        when age < 18 then 'Child'
        when age between 18 and 60 then 'adult'
        else 'senior'
   end as age_group,
round(avg(survived),2)as survival_rate
from train
group by age_group
	
--2.Using a window function to rank passengers by fare within each class
select
 dense_rank()over(partition by pclass order by fare desc) as rank,pclass,fare,passengerid
from train

--3.Find the top 3 most expensive tickets
select fare
from train
order by fare desc
limit 3

--4.Using CTE to calculate the average fare and find passengers who paid above average
with avg_fare as (select round(avg(fare),2) as avg_fare
from train)
select name,pclass,fare
from train
where fare > (select * from avg_fare)
order by fare desc

--5.Calculate the total number of family members on board (SibSp + Parch) and average family size
select round(avg(sibsp+parch)) as Average_family_size
from train

--6.Find passengers who shared the same ticket
select T1.Name as Passenger1, T2.Name as Passenger2, T1.Ticket
from train T1
join test T2
on T1.Ticket = T2.Ticket and T1.PassengerId <> T2.PassengerId;

--7.Determine the survival rate of passengers with family members on board vs those without
select 
    case 
        when SibSp + Parch > 0 then 'With Family'
        else 'Alone'
    end as FamilyStatus,
    ROUND(avg(Survived),2) as Survival_Rate
from Train
group by FamilyStatus;

--8.List the names of passengers along with the number of family members
select name,(sibsp+parch+1) as Family_Members
from train
