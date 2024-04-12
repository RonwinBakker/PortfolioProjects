--Change table structure to ensure data is mapped to the correct fields
--We will create a new table with the correct structure
--Then insert the data from old table
--We will then drop the old table created with the import of the file
--Finally rename the new table


--USE [PortfolioProject]
--GO

--/****** Object:  Table [dbo].[CovidDeaths]    Script Date: 11-Apr-24 3:18:10 PM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [dbo].[CovidDeathsNew](
--	[iso_code] [nvarchar](255) NULL,
--	[continent] [nvarchar](255) NULL,
--	[location] [nvarchar](255) NULL,
--	[date] [datetime] NULL,
--	[population] [bigint] NULL,
--	[total_cases] [int] NULL,
--	[new_cases] [int] NULL,
--	[new_cases_smoothed] [float] NULL,
--	[total_deaths] [int] NULL,
--	[new_deaths] [int] NULL,
--	[new_deaths_smoothed] [float] NULL,
--	[total_cases_per_million] [float] NULL,
--	[new_cases_per_million] [float] NULL,
--	[new_cases_smoothed_per_million] [float] NULL,
--	[total_deaths_per_million] [float] NULL,
--	[new_deaths_per_million] [float] NULL,
--	[new_deaths_smoothed_per_million] [float] NULL,
--	[reproduction_rate] [float] NULL,
--	[icu_patients] [int] NULL,
--	[icu_patients_per_million] [float] NULL,
--	[hosp_patients] [int] NULL,
--	[hosp_patients_per_million] [float] NULL,
--	[weekly_icu_admissions] [int] NULL,
--	[weekly_icu_admissions_per_million] [float] NULL,
--	[weekly_hosp_admissions] [int] NULL,
--	[weekly_hosp_admissions_per_million] [float] NULL,
--	[total_tests] [int] NULL
--) ON [PRIMARY]
--GO

--INSERT INTO [dbo].[CovidDeathsNew]
--           ([iso_code]
--           ,[continent]
--           ,[location]
--           ,[date]
--           ,[population]
--           ,[total_cases]
--           ,[new_cases]
--           ,[new_cases_smoothed]
--           ,[total_deaths]
--           ,[new_deaths]
--           ,[new_deaths_smoothed]
--           ,[total_cases_per_million]
--           ,[new_cases_per_million]
--           ,[new_cases_smoothed_per_million]
--           ,[total_deaths_per_million]
--           ,[new_deaths_per_million]
--           ,[new_deaths_smoothed_per_million]
--           ,[reproduction_rate]
--           ,[icu_patients]
--           ,[icu_patients_per_million]
--           ,[hosp_patients]
--           ,[hosp_patients_per_million]
--           ,[weekly_icu_admissions]
--           ,[weekly_icu_admissions_per_million]
--           ,[weekly_hosp_admissions]
--           ,[weekly_hosp_admissions_per_million]
--           ,[total_tests])
--     select [iso_code]
--           ,[continent]
--           ,[location]
--           ,[date]
--           ,[population]
--           ,[total_cases]
--           ,[new_cases]
--           ,[new_cases_smoothed]
--           ,[total_deaths]
--           ,[new_deaths]
--           ,[new_deaths_smoothed]
--           ,[total_cases_per_million]
--           ,[new_cases_per_million]
--           ,[new_cases_smoothed_per_million]
--           ,[total_deaths_per_million]
--           ,[new_deaths_per_million]
--           ,[new_deaths_smoothed_per_million]
--           ,[reproduction_rate]
--           ,[icu_patients]
--           ,[icu_patients_per_million]
--           ,[hosp_patients]
--           ,[hosp_patients_per_million]
--           ,[weekly_icu_admissions]
--           ,[weekly_icu_admissions_per_million]
--           ,[weekly_hosp_admissions]
--           ,[weekly_hosp_admissions_per_million]
--           ,[total_tests] 
--		   from [dbo].[CovidDeaths]
--GO
--/****** Object:  Table [dbo].[CovidDeaths]    Script Date: 11-Apr-24 3:18:10 PM ******/

----Rename manually
--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CovidDeaths]') AND type in (N'U'))
--DROP TABLE [dbo].[CovidDeaths$]
--GO

--EXEC sp_rename 'CovidDeathsNew', 'CovidDeaths'

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

