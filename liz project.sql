--SELECT*
--FROM [LizNewProject ]..CovidDeaths
--order by 3,4

--SELECT*
--FROM [LizNewProject ]..CovidVaccines
--order by 3,4


--looking at Total cases vs Total Deaths
SELECT location, date, total_cases, Total_deaths, (Total_deaths/total_cases)*100 as Death_percentage
From [LizNewProject ]..CovidDeaths
WHERE Location like  '%states%'
ORDER BY 1,2



--Looking at the Total cases vs Total Population 
--shows what percentage of the population got covid
SELECT location, date, total_cases,population, (total_cases/population)*100 as Cases_percentage
FROM [LizNewProject ]..CovidDeaths
WHERE location like '%states%'
order by 1,2


--looking at the countries with the highest infection rate compared to the population
SELECT location, population, Max(total_cases), Max((total_cases/population))*100 as highest_infection_rate
From [LizNewProject ]..CovidDeaths
group by location, population
order by highest_infection_rate desc

--showing countries with the highest death count 
SELECT location, Max (cast(total_deaths as int)) as highest_death_count
from [LizNewProject ]..CovidDeaths
where continent is not null
group by location
order by highest_death_count desc


--lets break things down in continents
-- showing continents with the highest death count per population
SELECT continent, Max (cast(total_deaths as int)) as highest_death_count
from [LizNewProject ]..CovidDeaths
where continent is not null
group by continent
order by highest_death_count desc

--where continent is null
SELECT location, Max (cast(total_deaths as int)) as highest_death_count
from [LizNewProject ]..CovidDeaths
where continent is  null
group by location
order by highest_death_count desc

SELECT date, SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths,SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as new_death_percentage
from [LizNewProject ]..CovidDeaths
where continent is not null
group by date
order by 1, 2

--JOINING TWO TABLES TOGETHER

SELECT*
FROM [LizNewProject ]..CovidDeaths dea
join [LizNewProject ]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
order by 1, 2

--looking at total population vs new vaccinations
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(Cast(vac.new_vaccinations as int)) over(
partition by dea.location order by dea.location,dea.date )as rollingpeoplevaccinated
FROM [LizNewProject ]..CovidDeaths dea
join [LizNewProject ]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(Cast(vac.new_vaccinations as int)) over(
partition by dea.location order by dea.location,dea.date )as rollingpeoplevaccinated
FROM [LizNewProject ]..CovidDeaths dea
join [LizNewProject ]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select*
from popvsvac


---TEMP TABLE
DROP TABLE if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(Cast(vac.new_vaccinations as int)) over(
partition by dea.location order by dea.location,dea.date )as rollingpeoplevaccinated
FROM [LizNewProject ]..CovidDeaths dea
join [LizNewProject ]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select*
from #percentpopulationvaccinated


--create view to store data for later visualization

create view percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(Cast(vac.new_vaccinations as int)) over(
partition by dea.location order by dea.location,dea.date )as rollingpeoplevaccinated
FROM [LizNewProject ]..CovidDeaths dea
join [LizNewProject ]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select*
from percentpopulationvaccinated







