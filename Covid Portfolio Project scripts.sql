select *
from Covid_Portfolio_Project..Covid_Deaths
order by 3,4

-- select *
-- from Covid_Portfolio_Project..Covid_Vaccinations
-- order by 3,4

-- Selecting data to work with

 select Location, date, total_cases, new_cases, total_deaths, population
 from Covid_Portfolio_Project..Covid_Deaths
 order by 1,2;


 -- Total cases vs Total deaths
 select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
 from Covid_Portfolio_Project..Covid_Deaths
 order by 1,2;

alter table Covid_Portfolio_Project..Covid_Deaths
alter column new_deaths int

ALTER TABLE Covid_Portfolio_Project..Covid_Deaths
ALTER COLUMN population BIGINT;

--Looking at the total number of deaths and death percentage by country, Cameroon
-- This value show the likelihood of dying if you contract COVID in Cameroon during these periods

select location, date, total_cases, total_deaths, 
    case 
        when total_cases = 0 then 0
	    else (cast(total_deaths as float)/total_cases)*100
    end as Deathpercentage
from Covid_Portfolio_Project..Covid_Deaths
where location like'camer%'
order by 1,2;

-- Exploring the total_cases with respect to the population

 select location, date, total_cases, population, 
    case 
        when total_cases = 0 then 0
	    else (cast(total_cases as float)/population)*100
    end as Popinfected
from Covid_Portfolio_Project..Covid_Deaths
where location like'camer%'
order by 1,2;

-- Exploring countries with the highest infection rate vs its population

select location, population, max(total_cases) as highestinfec_location,  
    case 
        when population = 0 then 0
	    else (cast(max(total_cases) as float)/population)*100
    end as highestinfectionrate
from Covid_Portfolio_Project..Covid_Deaths
group by location, population
order by highestinfectionrate desc;

-- evaluating the countries with the highest death count per population

select location, Max(total_deaths) as maxdeathcount
from Covid_Portfolio_project..Covid_Deaths
where continent <> ''
group by location
order by maxdeathcount desc;

-- exploring data by continents
select continent, Max(total_deaths) as maxdeathcount
from Covid_Portfolio_project..Covid_Deaths
where continent <>''
group by continent
order by maxdeathcount desc;

select location, Max(total_deaths) as maxdeathcount
from Covid_Portfolio_project..Covid_Deaths
where continent =''
group by location
order by maxdeathcount desc;

-- Global stats

select 
    date,
	sum(new_cases) as totalnewcases,
	sum(new_deaths) as totalnewdeaths,
	(sum(cast(new_deaths as float))/nullif(sum(new_cases),0))*100 as deathpercentage
from 
    Covid_Portfolio_Project..Covid_Deaths
where 
    continent <>''
group by 
    date
order by 
    1,2;

select 
	sum(new_cases) as totalnewcases,
	sum(new_deaths) as totalnewdeaths,
	(sum(cast(new_deaths as float))/nullif(sum(new_cases),0))*100 as deathpercentage
from 
    Covid_Portfolio_Project..Covid_Deaths
where 
    continent <>''
order by 
    1,2;

-- joining the two tables based off of the location and date
-- looking at total population vs vaccination
select CD.continent,CD.location, CD.date, CD.population, Cv.new_vaccinations,
sum(cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location,CD.date) as rollingpopvaccinated
from Covid_Portfolio_Project..Covid_Deaths as CD
join Covid_Portfolio_Project..Covid_Vaccinations as CV
    on CD.location = CV.location
	and CD.date = CV.date
where CD.continent <>''
order by 2,3;

--Using a CT

With popvsvac (continent, location, date, population, new_vaccinations, rollingpopvaccinated)
as
(
select CD.continent,CD.location, CD.date, CD.population, Cv.new_vaccinations,
sum(cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location,CD.date) as rollingpopvaccinated
from Covid_Portfolio_Project..Covid_Deaths as CD
join Covid_Portfolio_Project..Covid_Vaccinations as CV
    on CD.location = CV.location
	and CD.date = CV.date
where CD.continent <>''
-- order by 2,3
)
select *, (cast(rollingpopvaccinated as float)/ nullif(cast(population as float),0))*100 as rollingpercentvac
from popvsvac;

	
--rolling average number of people vaccinated

with avgpopvac (continent,location, date,population, new_vaccinations, rollingavgvaccinated)
as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
avg(cast (CV.new_vaccinations as int)) over(partition by CD.location order by CD.location, CD.date) as rollingavgvaccinated
from Covid_Portfolio_Project..Covid_Deaths as CD
join Covid_Portfolio_Project..Covid_Vaccinations as CV
    on CD.location = CV.location
	and CD.date = CV.date
where CD.continent<>''
)
select *, (cast(rollingavgvaccinated as float)/nullif(cast(population as float),0))*100 as rollingavgvac
from avgpopvac
order by location;

-- temp table
drop table if exists #Percentpopvac
create table #Percentpopvac
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations nvarchar(255),
rollingsumvac numeric
)

insert into #Percentpopvac
select D.continent, D.location, D.date, D.population, V.new_vaccinations,
sum(cast (V.new_vaccinations as int)) over(partition by D.location order by D.location, D.date) as rollingsumvac
from Covid_Portfolio_Project..Covid_Deaths as D
join Covid_Portfolio_Project..Covid_Vaccinations as V
    on D.location = V.location
	and D.date = V.date
where D.continent<>''

select *, (cast(rollingsumvac as float)/nullif(cast(population as float),0))*100 as rollingpervac
from #Percentpopvac
order by location;


-- creating view for datastorage - visualization

create view Percentpopvac as
select D.continent, D.location, D.date, D.population, V.new_vaccinations,
sum(cast (V.new_vaccinations as int)) over(partition by D.location order by D.location, D.date) as rollingsumvac
from Covid_Portfolio_Project..Covid_Deaths as D
join Covid_Portfolio_Project..Covid_Vaccinations as V
    on D.location = V.location
	and D.date = V.date
where D.continent<>''



DROP VIEW maxdeathcount;

CREATE VIEW dbo.maxdeathcount AS
select continent, Max(total_deaths) as maxdeathcount
from Covid_Portfolio_project..Covid_Deaths
where continent <>''
group by continent;


