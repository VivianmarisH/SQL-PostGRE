/*
COVID 2019 DATA EXPLORATION 
SKILLS : JOINS, CTE's, TEMP TABLES, WINDOWS FUNCTIONS, AGGREGATE FUNCTIONS, CREATING VIEWS, CONVERTING DATA TYPES
*/

select *
from CovidDeath
where continent is not null
order by 3,4

select *
from Covidvaccination
order by 3,4

******

--select location, date, total_cases, new_cases, total_deaths, population
--from Coviddeath
--order by 1,2

--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from Coviddeath
--order by 1,2

-- TOTAL CASES VS TOTAL DEATH
-- LIKELIHOOD TO DIE AFTER CONTRACTING COVID IN YOUR COUNTRY

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Coviddeath
where location like '%Asia%'
order by 1,2

-----TOTAL CASE VS POPULATION (shows %age of population with covid)

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from Coviddeath
where location like '%Asia%'
order by 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARE TO POPULATION

select location, population, max(total_cases) as Highestinfectioncount, max(total_cases/population)*100 as PercentagePopulationInfected
from Coviddeath
where continent is not null
group by location, population
order by PercentagePopulationInfected desc	

--SHOWING THE COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

select location, max(total_deaths) as Totaldeathcount
from Coviddeath
where continent is not null
group by location
order by Totaldeathcount desc	

--BREAKING DOWN BY CONTINENT (highest death count per population)

select location, max(cast(total_deaths as int)) as Totaldeathcount
from Coviddeath
where continent is not null
group by location
order by Totaldeathcount desc	

select location, max(cast(total_deaths as int)) as Totaldeathcount
from Coviddeath
where continent is null
group by location
order by Totaldeathcount desc	

select continent, max(cast(total_deaths as int)) as Totaldeathcount
from Coviddeath
where continent is not null
group by continent
order by Totaldeathcount desc	

--SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT/GLOBAL NUMBERS

select date, sum(new_cases) ---,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Coviddeath
where continent is not null
group by date
order by 1,2

select date, sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from Coviddeath
where continent is not null
group by date
--order by 1,2

--CALCULATING TOTAL DEATH AND PERCENTAGE

select sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from Coviddeath
where continent is not null
order by 1,2


----LOOKING AT TOTAL POPULATION VS VACCINATION


select *
--from Coviddeath dea
--join Covidvaccination vac
--	on dea.location = vac.location
--	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population
from Coviddeath dea
join Covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
order by 2,3


-- USING CTE TO PERFORM CALCULATION ON PARTITION BY


select dea.continent, dea.location, dea.date, dea.population
from Coviddeath dea
join Covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccination
sum(vac.new_vaccination as int) over (partition by dea.location),
-- (RollingPeopleVaccinated/population)*100
from Coviddeath dea
join Covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- USING TEMP TABLE TO PERFORM CALCULATION ON PARTITION BY 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from coviddeath dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATA VISUALISATIONS


create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeoplevaccinated/population)*100
from coviddeaths dea
Join covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



