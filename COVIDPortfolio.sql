SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccionations$
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths	
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, ((TRY_CONVERT (float, [total_deaths]))/(TRY_CONVERT(float, [total_cases])))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%Brazil%' and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, Population, total_cases, ((TRY_CONVERT (float, [total_cases]))/(TRY_CONVERT(float, [Population])))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where Location like '%Brazil%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, (MAX((TRY_CONVERT (float, [total_cases]))/(TRY_CONVERT(float, [Population]))))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where Location like '%Brazil%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(TRY_CONVERT (float, [total_deaths])) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where Location like '%Brazil%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Let's break things down by continent

SELECT continent, MAX(TRY_CONVERT (float, [total_deaths])) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where Location like '%Brazil%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Showing continents with the highest death count per population

SELECT continent, MAX(TRY_CONVERT (float, [total_deaths])) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where Location like '%Brazil%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT SUM(TRY_CONVERT(float, [new_cases])) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(TRY_CONVERT(float, [new_cases]))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccionations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccionations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac



-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccionations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccionations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



SELECT *
FROM PercentPopulationVaccinated
