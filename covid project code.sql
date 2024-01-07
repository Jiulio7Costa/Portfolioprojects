
select *
from coviddeaths
order by 3,4;

select *
from covid_vaccinations
order by 3,4;
select count(*) from coviddeaths;
 
select count(*) from covid_vaccinations;

select Location,date,total_cases,new_cases,total_deaths,population
from coviddeaths
order by 1,2;

-- lOOKING AT TOTAL CASES VS TOTAL DEATHS

SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
WHERE Location like '%lanka%'
order by 1,2;

-- Looking at Total Cases vs Population
-- shows what population got covid

SELECT Location,date,total_cases,total_deaths,(total_cases/population)*100 as DeathPercentage
from coviddeaths
WHERE Location like '%italy%'
order by 1,2;

-- Looking at countries with highest infection rate compared to Population

SELECT Location,Population,Max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 AS PercentPopulationInfected
from coviddeaths
-- WHERE Location like '%italy%'
Group by location,Population
order by PercentPopulationInfected desc;

-- showing Countries with the highest death count

SELECT Location,MAX(CAST(CASE WHEN total_deaths REGEXP '^[0-9]+$' THEN total_deaths ELSE 0 END AS SIGNED)) AS TotalDeathCount
from coviddeaths
-- WHERE Location like '%italy%'
where continent is not null
Group by location
order by TotalDeathCount desc;

-- Let's Break Things down by continent
SELECT location,MAX(CAST(CASE WHEN total_deaths REGEXP '^[0-9]+$' THEN total_deaths ELSE 0 END AS SIGNED)) AS TotalDeathCount
from coviddeaths
-- WHERE Location like '%italy%'
where continent is  null
Group by location
order by TotalDeathCount desc;

select continent,  sum(new_deaths) as TotalDeath
from coviddeaths
where continent!=''
group by continent;

-- Global Numbers

SELECT date,SUM(max_new_cases) AS TotalMaxNewCases
FROM (SELECT date,
        MAX(new_cases) AS max_new_cases
    FROM coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY date
) AS subquery
GROUP BY date
ORDER BY 1,2;


Select  SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths AS SIGNED)) as total_deaths,
    (SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100 as DeathPercentage
From CovidDeaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;

-- Looking at Total Population vs Vaccinations
-- CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as signed)) over (partition by dea.Location order by dea.Location,dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
from coviddeaths dea
join covid_vaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
-- order by 2,3
 )
 select *, (RollingPeopleVaccinated/Population)*100
 from PopvsVac;
 
 -- TEMP TABLE
 DROP Table if exists PercentPopulationVaccinated;
Create temporary table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
);

 
 
 insert into PercentPopulationVaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as signed)) over (partition by dea.Location order by dea.Location,dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
from coviddeaths dea
join covid_vaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date;
--  where dea.continent is not null
-- order by 2,3

 select *, (RollingPeopleVaccinated/Population)*100
 from PercentPopulationVaccinated;
 
 -- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as signed)) over (partition by dea.Location order by dea.Location,dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
from coviddeaths dea
join covid_vaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
-- order by 2,3;
