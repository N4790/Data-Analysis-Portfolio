/*
Covid 19 Data Exploration 
Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Casting & Converting Data Types
*/


-- Starting Data

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Where continent is not null 
order by location,date


-- Total Cases vs Total Deaths over time
-- (Using the Netherlands as an example)

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject1..CovidDeaths
Where location = 'Netherlands'
and continent is not null 
order by date


-- Total Cases vs Population
-- Shows percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as percentage_of_population_infected
From PortfolioProject1..CovidDeaths
order by location,date


-- Countries with highest infection rate at any time

Select Location, Population, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percentage_of_population_infected
From PortfolioProject1..CovidDeaths
Group by Location, Population
order by percentage_of_population_infected desc


-- Countries with highest death count relative to population

Select Location, MAX(cast(Total_deaths as int)) as total_death_count
From PortfolioProject1..CovidDeaths
Where continent is not null 
Group by Location
order by total_death_count desc



-- Deaths by continent

Select continent, MAX(cast(Total_deaths as int)) as total_death_count
From PortfolioProject1..CovidDeaths
Where continent is not null 
Group by continent
order by total_death_count desc



-- Global deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_percentage
From PortfolioProject1..CovidDeaths
where continent is not null 



-- Percentage of population that has received at least one vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as cumulative_vaccinations
--, (cumulative_vaccinations/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by dea.location,dea.date



-- Using temp table to perform calculation on 'partition by' clause in previous query

DROP Table if exists #percentage_of_population_vaccinated
Create Table #percentage_of_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cumulative_vaccinations numeric
)

Insert into #percentage_of_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as cumulative_vaccinations
--, (cumulative_vaccinations/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by dea.location,dea.date

Select *, (cumulative_vaccinations/Population)*100 AS Percentage_of_population_vaccinated
From #percentage_of_population_vaccinated



-- Creating View to store data for later visualisations

Create View percentage_of_population_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as cumulative_vaccinations
--, (cumulative_vaccinations/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
