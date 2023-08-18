
/*
Portfolio project doing some data exploration on Covid 19 data.
Setting up data to be used in Tableau.
*/


-- Main Data to be looked at.

Select location, date, total_cases, new_cases, total_deaths, population 
From CovidPortfolioProject..CovidDeaths$
Where continent is not null
order by location, date

-- Total Cases vs Total Deaths in the world as %
-- Shows % chance of death if contracted Covid

Select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentageWorld
From CovidPortfolioProject..CovidDeaths$
Where continent is not null
order by location, date


-- Total Cases vs Total Deaths in Botswana as %
-- Shows % chance of death if contracted Covid

Select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentageBotswana
From CovidPortfolioProject..CovidDeaths$
Where continent is not null
and location like '%Bots%'
order by location, date


-- Total Cases Vs Population in the world as a %

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentageWorld
From CovidPortfolioProject..CovidDeaths$
Where continent is not null
order by location, date


-- Total Cases vs Population in Botswana as a %

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentageBotswana
From CovidPortfolioProject..CovidDeaths$
Where continent is not null
and location like '%Bots%'
order by location, date


-- Highest Infection rate VS Population
-- Ranked from highest to lowest

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths$
Where continent is not null
--where location like '%Bots%'
Group by location, population
order by PercentPopulationInfected desc


-- Countries with highest death count vs population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths$
Where continent is not null
group by location
order by TotalDeathCount desc


-- Continents with highest death count vs population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths$
Where continent is null
group by location
order by TotalDeathCount desc


/*
GLOBAL NUMBERS
*/

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From CovidPortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2


-- Total Cases vs Total Deaths
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From CovidPortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


-- Join CovidDeaths and CovidVaccinations Tables 

Select *
From CovidPortfolioProject..CovidDeaths$ as dea
Join CovidPortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Total Vacinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidPortfolioProject..CovidDeaths$ as dea
Join CovidPortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date


-- Rolling Count of Daily Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths$ as dea
Join CovidPortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date


-- % of people vaccinated per country using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths$ as dea
Join CovidPortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by dea.location, dea.date
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths$ as dea
Join CovidPortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by dea.location, dea.date

Select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From #PercentPopulationVaccinated
order by location


/*
Views for visualisations
*/


-- Percentage Vaccinated View

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths$ as dea
Join CovidPortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by dea.location, dea.date


-- Rolling Count of Daily Vaccinations

Create View RollingCountDailyVaccinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths$ as dea
Join CovidPortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by dea.location, dea.date


-- Total Population vs Total Vacinations

Create View TotalPopulationvsTotalVacinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidPortfolioProject..CovidDeaths$ as dea
Join CovidPortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by dea.location, dea.date


-- Total Population vs Total Vacinations

Create View TotalPopulationsvsTotalVaccinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidPortfolioProject..CovidDeaths$ as dea
Join CovidPortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by dea.location, dea.date



