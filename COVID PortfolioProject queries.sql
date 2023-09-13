SELECT * FROM covid_deaths;

-- looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases) * 100, 2) as death_percentage FROM covid_deaths
where continent is not null
order by location, date;

-- looking at total cases vs population
SELECT location, date, total_cases, population, round((total_cases/population) * 100, 2) as case_percentage FROM covid_deaths
where continent is not null
order by location, date;

-- looking at countries with highest infection rate compared to population
SELECT location, population, max(total_cases) as highest_infection, max(round((total_cases/population) * 100, 2)) as case_percentage FROM covid_deaths
where continent is not null
group by location, population
order by case_percentage desc; 

-- looking at the death stats
select location, 
	population, 
    max(total_cases) total_cases, 
    max(total_deaths) as total_deaths,
    round((max(total_deaths) / sum(total_cases)) * 100, 2)  as perc_of_deaths_to_cases,
    round((max(total_deaths) / population) *100, 2) as perc_of_deaths_to_population
    from covid_deaths
where continent is not null
group by location, population;

SELECT * FROM covid.covid_deaths;

-- total death count by continent
select continent, max(total_deaths) as "death_count" from covid_deaths
where continent <> ""
group by continent
order by death_count desc;

-- GLOBAL
select max(total_cases), max(total_deaths), round((max(total_deaths) / max(total_cases)) * 100, 3) as "death_percentage" from covid_deaths;

-- GLOBAL month and year
select monthname(date) as "month", 
	   year(date) as "year", 
       max(total_cases) as "total_cases", 
       max(total_deaths) as "total_deaths",
       round((max(total_deaths) / max(total_cases)) * 100, 2) as "death_perc_to_cases"
       from covid_deaths
group by year, month
order by month;

SELECT * FROM covid.covid_vaccinations;
SELECT * FROM covid.covid_deaths;

-- total population vs vaccinations
select a.location, max(population) as "population", max(total_vaccinations) as "vaccinations" from covid_deaths a 
join covid_vaccinations b
	on a.location = b.location and a.date = b.date
group by a.location;   

-- total population vs nos of people vaccinated/fully vaccinated
select a.location, max(population) as "population", max(people_vaccinated) as "people_vaccinated_atleast_once", max(people_fully_vaccinated) as "people_fully_vaccinated" from covid_deaths a 
join covid_vaccinations b
	on a.location = b.location and a.date = b.date
group by a.location;   


-- total population vs new vaccinations
-- adds up every consecutive vaccinations
-- running count of vaccinations
select a.continent, 
	   a.location, 
       a.date, 
       a.population, 
       b.new_vaccinations,
       sum(b.new_vaccinations) over(partition by location order by a.location, a.date) as "running_count_of_vaccinations"
       from covid_deaths a 
join covid_vaccinations b
	on a.location = b.location and a.date = b.date
where a.continent <> "";
 
-- using CTE on the above table for additional queries
with runningcount (continent, location, date, population, new_vaccinations, running_count_of_vaccinations)
as
(select a.continent, 
	   a.location, 
       a.date, 
       a.population, 
       b.new_vaccinations,
       sum(b.new_vaccinations) over(partition by location order by a.location, a.date) as running_count_of_vaccinations
       from covid_deaths a 
join covid_vaccinations b
	on a.location = b.location and a.date = b.date
where a.continent <> "")

select *, (running_count_of_vaccinations / population) * 100 from runningcount;

-- temp table 
create table #percent_people_vaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, running_count_of_vaccinations numeric)

insert into #percent_people_vaccinated

select a.continent, 
	   a.location, 
       a.date, 
       a.population, 
       b.new_vaccinations,
       sum(b.new_vaccinations) over(partition by location order by a.location, a.date) as running_count_of_vaccinations
       from covid_deaths a 
join covid_vaccinations b
	on a.location = b.location and a.date = b.date
where a.continent <> ""

select *, (running_count_of_vaccinations / population) * 100 from percent_people_vaccinated





