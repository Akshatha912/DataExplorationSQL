select *
from portfolioProject..CovidDeaths
order by 3,4

--select *
--from portfolioProject..CovidVaccinations
--order by 3,4

--select data that will be used
select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..CovidDeaths
order by 1,2

--total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject..CovidDeaths
WHERE location like '%India%'
order by 1,2

--total cases vs population  shows percentage of people who got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from portfolioProject..CovidDeaths
WHERE continent is not null
WHERE location like '%India%'
order by 1,2

--countries with highest infection rate compared to population
select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
order by PercentPopulationInfected desc

--countries with highest death count per population  cast is used to make the datatype of total deaths as int  
select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

--as continent this excludes some countries
select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

--using locations along with null values gives accurate result
select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
order by TotalDeathCount desc

--global numbers
select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/(sum(new_cases)) * 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
group by date
order by 1,2

--total cases when group by date is removed
select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/(sum(new_cases)) * 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
order by 1,2

--using covid vaccinations table
select * 
from PortfolioProject..CovidVaccinations

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RolingPeopleVaccinated --can use convert(int) also instead of cast
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using CTE to get percentage of people vaccinated per day

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RolingPeopleVaccinated --can use convert(int) also instead of cast
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--using temp table to get percentage of people vaccinated per day

DROP TABLE IF EXISTS #PercentPopulationVaccinated --THIS ENABLES RUNNING TABLE MULTIPLE TIMES
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RolingPeopleVaccinated --can use convert(int) also instead of cast
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RolingPeopleVaccinated --can use convert(int) also instead of cast
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated















--



