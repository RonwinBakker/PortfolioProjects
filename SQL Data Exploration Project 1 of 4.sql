/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc












-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out

--select Data that we are going to be using


SELECT continent,location,date,total_cases,new_cases,new_deaths,total_deaths,population
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null and new_cases is not null
  order by 1,2

--Looking at Total Cases vs Total Deaths convert int to float to avoid zero due to integer answer.
--Shows the likelyhood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100.0 as DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where total_cases is not null and total_deaths is not null and continent is not null
  and location = 'South Africa'
  order by 3 desc

--Looking at Total Cases vs population convert int to float to avoid zero due to integer answer.
--Shows what percentage of population got covid

SELECT location,date,population,total_cases,(cast(total_cases as float)/cast(population as float))*100.0 as PercentPopulationInfected
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where total_cases is not null and continent is not null
  and location = 'South Africa'
  order by 3 desc

--Looking at Countries with Highest Infection Rate compared to population
--Shows what percentage of population got covid

  SELECT location,population,max(total_cases) as HighestInfectionCount, max(cast(total_cases as float)/cast(population as float))*100.0 as PercentPopulationInfected
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where total_cases is not null and continent is not null
  and location = 'United States'
  group by location,population
  order by PercentPopulationInfected desc

--Looking at Countries with Highest Death Count compared to population
--Shows what percentage of population got covid

  SELECT location,max(cast(total_deaths as int)) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where total_deaths is not null and continent is not null
  --and location = 'United States'
  group by location
  order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

  SELECT continent,max(cast(total_deaths as int)) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where total_deaths is not null and continent is not null
  --and location = 'United States'
  group by continent
  order by TotalDeathCount desc

  SELECT location,max(cast(total_deaths as int)) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where total_deaths is not null and continent is null
  --and location = 'United States'
  group by location
  order by TotalDeathCount desc

-- Global numbers
SELECT sum(new_cases),sum(new_deaths),sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100.0 as DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null and (isnull(new_cases,0) > 0)-- and isnull(new_deaths,0) > 0)
  --group by date
  --and location = 'South Africa'
  order by 3 desc

--SELECT *
--  FROM [PortfolioProject].[dbo].[CovidVaccinations]
--  order by 3,4
select 34571873/5882259

--total population vs vaccinations

select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinationCount
from portfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
order by 1,2

--use TempTable (#)
drop table if exists #PopvsVac

select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations as New_Vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinationCount
into #PopvsVac
from portfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *,(RollingVaccinationCount/population)*100 from #PopvsVac

select continent,location,population, max((RollingVaccinationCount/population)*100) as MaxRollingVaccinationCount
from #PopvsVac
group by continent,location,population

--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations as New_Vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinationCount
from portfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

