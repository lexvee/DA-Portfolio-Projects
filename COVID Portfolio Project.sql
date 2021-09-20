Select*
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data to use

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


--Total Cases Vs Total Deaths
--Likelihood of Covid death by those infected
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


--Total Cases Vs Population
select location, date, total_cases, new_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
Order by 1,2

--Highest infection rate locations
select location,population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as CasePercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
Order by CasePercentage desc

-- Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
Order by total_death_count desc

-----Breakdown by continent
--select continent, MAX(cast(total_deaths as int)) as total_death_count
--From PortfolioProject..CovidDeaths
----where location like '%states%'
--where continent is not null
--group by continent
--Order by total_death_count desc


---Breakdown by continent
select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
Order by total_death_count desc

--Global Numbers
--select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----where location like '%states%'
--where continent is not null
--Group by date
--order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-- Total population vs vaccinations
--Join tw sepate tables
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as cumulative_vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, cumulative_vaccination)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as cumulative_vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select*, (cumulative_vaccination/population)*100
from PopvsVac


--Temp Table
Drop table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
cumulative_vaccination numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as cumulative_vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select*, (cumulative_vaccination/population)*100
from #PercentPopulationVaccinated

--Create view to store data for visualization
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as cumulative_vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated
