-- creating database
-- create database datasets;
use datasets;

-- data in tables was imported using import wizard
-- checking tables present in our database
show tables from datasets;

-- checking our data using select all
select * from dataset1;
select * from dataset2;

-- number of rows in our datasets
select count(*) from dataset1;
select count(*) from dataset2;

-- selecting data based on some attribute
select * from dataset1 
where state in ("jharkhand", "bihar");

-- sum function, total population of India
select sum(population) as total_population from dataset2;

-- avg function, avg growth of India
select avg(growth)*100 as avg_growth from dataset1;

-- aggregate functions
-- group by and order by clauses, growth per state ordered alphabetically by state name
-- both group by and order by clauses can work with multiple attributes
select state, avg(growth)*100 as avg_growth from dataset1 
group by state 
order by state;

-- avg sex ratio by state rounded
select state, round(avg(sex_ratio), 0) as avg_sex_ratio from dataset1 
group by state 
order by avg_sex_ratio;

-- having clause, states where literacy rate is greater than 90%
select state, avg(literacy) as literacy_rate from dataset1 
group by state 
having avg(literacy)>90 
order by literacy_rate;

-- top 3 growing states 
select state, avg(growth)*100 as avg_growth from dataset1 
group by state 
order by avg(growth)*100 desc
limit 3;

-- bottom 3 literate states
select state, avg(literacy) as literacy_rate from dataset1 
group by state  
order by literacy_rate
limit 3;

-- 3 most and 3 least literate states with temporary tables and unions
-- temp table for most literate states
drop table if exists upper;
create temporary table upper(
state varchar(255),
rate double
);
-- inserting from another table
insert into upper
select state, avg(literacy) as literacy_rate from dataset1 
group by state 
order by literacy_rate desc;

select * from upper;

-- temp table for least literate states
drop table if exists lower;
create temporary table lower(
state varchar(255),
rate double
);
-- inserting from another table
insert into lower
select state, avg(literacy) as literacy_rate from dataset1 
group by state 
order by literacy_rate;

select * from lower;

-- union
(select * from upper limit 3)
union
(select * from lower limit 3)
order by rate desc;

-- states with names containing certain characters
-- a% starting with a
-- %a ending with a
-- %a% containing a in between anywhere
select distinct state from dataset1 
where state like '%a%' and state like '%b%';

-- also using underscore defines how many letters we want before or after
select distinct state from dataset1 
where state like 'a__a_';

-- joins 
-- finding total number of people in both genders in India
-- divide sex_ratio by 1000 because it is represented by an integer per 1000
select c.district, c.state, round((c.population/(c.sex_ratio+1)), 0) as males, round((c.population*c.sex_ratio/(c.sex_ratio+1)), 0) as females from
(select a.district, a.state, a.sex_ratio/1000 as sex_ratio, b.population from dataset1 a 
join dataset2 b 
on a.district = b.district) as c;

-- by state
select d.state, sum(d. males) as males, sum(d.females) as females from
(select c.district, c.state, round((c.population/(c.sex_ratio+1)), 0) as males, round((c.population*c.sex_ratio/(c.sex_ratio+1)), 0) as females from
(select a.district, a.state, a.sex_ratio/1000 as sex_ratio, b.population from dataset1 a 
join dataset2 b 
on a.district = b.district) as c) as d
group by d.state;

-- population in previous census using current population and growth rate by joining both tables
select d.state, sum(d.pop_prev) as pop_prev, sum(d.pop_curr) as pop_curr from
(select c.district, c.state, round(c.population/(1+c.growth), 0) as pop_prev, c.population as pop_curr from
(select a.district, a.state, a.growth, b.population from dataset1 a 
inner join dataset2 b 
on a.district = b.district) c) d
group by d.state;

-- bottom 3 literate districts per state using window functions
select * from
(select district, state, literacy, rank()
over(
	partition by state
    order by literacy) rnk
from dataset1) a
where a.rnk in (1, 2, 3)
order by a.state;