select *
from socialmedia_mentalhealth..MH_ITpersonnel;

-- 1. Global number of IT personnel who seek traetment for mentalhealth

select count(*) total_workers, 
    sum(case when treatment = 'Yes' then 1 else 2 end ) as sought_treatmeat,
	round((cast(sum(case when treatment = 'Yes' then 1 else 2 end) as float)/count(*))*100, 2) as percent_ontreatment
from socialmedia_mentalhealth..MH_ITpersonnel;

-- 2. Number of people who seek treatment per country
select Country, count(case when treatment = 'Yes' then 1 end ) as sought_treatment,
count(case when treatment = 'No' then 1 end  ) as didntseek_treatmemt,
round((cast(sum(case when treatment = 'Yes' then 1 else 0 end) as float)/count(*))*100,2) as percnt_ontrt
from socialmedia_mentalhealth..MH_ITpersonnel
group by Country
order by sought_treatment desc;

-- 3. Gender based MH staus and treatment

select Gender, count(*) totalresponse
from socialmedia_mentalhealth..MH_ITpersonnel
group by Gender
order by 2 desc;

--4. Treatment enrollment by gender

select Gender, count(case when treatment = 'Yes' then 1 end ) as sought_treatment,
count(case when treatment = 'No' then 1 end  ) as didntseek_treatmemt,
round((cast(sum(case when treatment = 'Yes' then 1 else 0 end) as float)/count(*))*100,2) as percnt_ontrt
from socialmedia_mentalhealth..MH_ITpersonnel
group by Gender
order by 2 desc;


-- . Readiness to seek help amongst age groups
drop table if exists #age_class;

select 
    case 
	    when Age between 18 and 25 then '18-25'
		when Age between 26 and 35 then'26-35'
		when Age between 36 and 45 then'36-45'
		when Age between 46 and 55 then'46-55'
		when Age between 56 and 65 then'56-65'
		else '<18or>65'
	end as age_group, 
	count(case when treatment = 'Yes' then 1 end ) as sought_treatment,
    count(case when treatment = 'No' then 1 end  ) as didntseek_treatment,
	round((cast(sum(case when treatment = 'Yes' then 1 else 0 end) as float)/count(*))*100,2) as percnt_ontrt
into #age_class
from socialmedia_mentalhealth..MH_ITpersonnel
where Age between 5 and 99
group by 
    case 
	    when Age between 18 and 25 then '18-25'
		when Age between 26 and 35 then'26-35'
		when Age between 36 and 45 then'36-45'
		when Age between 46 and 55 then'46-55'
		when Age between 56 and 65 then'56-65'
		else '<18or>65'
	end
;
-- 5. Readiness to seek help amongst age groups
select *
from #age_class
order by sought_treatment desc;

--6. treatment sought over time    
select datepart(YEAR, date) year, datepart(MONTH, date)  month,
  count(*) AS total_responses,
  sum(case when treatment = 'Yes' then 1 else 0 end) treated
from socialmedia_mentalhealth..MH_ITpersonnel
group by datepart(YEAR, date), datepart(MONTH, date)
order by year, month;

 -- 7. ranking countries by their readiness to seek help

 drop table if exists #countryrank;

 select Country, count(case when treatment = 'Yes' then 1 end ) as sought_treatment,
count(case when treatment = 'No' then 1 end  ) as didntseek_treatmemt,
round((cast(sum(case when treatment = 'Yes' then 1 else 0 end) as float)/count(*))*100,2) as percnt_ontrt
into #countryrank
from socialmedia_mentalhealth..MH_ITpersonnel
group by Country
order by sought_treatment desc;

select Country, sought_treatment,
    dense_rank()over(order by sought_treatment desc) countryrank
from #countryrank
where sought_treatment >0;
