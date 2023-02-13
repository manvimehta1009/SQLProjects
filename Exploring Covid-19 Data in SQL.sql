--EXPLORING GOVID-19 DATA--
--Checking the data--
SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4

--Selecting Data to be used--
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases VS Total Deaths--
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases VS Total Deaths for United States--
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE LOCATION like '%states%'
ORDER BY 1,2
--Shows he likelihood of dying if you contract covid in a particular country--

--Looking at Total Cases VS the Population--
SELECT Location,date,total_cases,Population,(total_cases/population)*100 as PercentageofPopinfected
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'--
order by 1,2

--For United States--
SELECT Location,date,total_cases,Population,(total_cases/population)*100 as PercentageofPopInfected
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states%'
order by 1,2
--Shows the percentage of population which got COVID--

--Looking at Countries with highest infection rates compared to populations--
SELECT Location,Population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentageofPopInfected
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'--
Group by Location, population
order by PercentageofPopInfected DESC


--Showing the Countries with the highest death rates--
SELECT Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE CONTINENT IS NOT NULL 
--WHERE Location like '%states%'--
Group by Location
order by TotalDeathCount DESC

--GROUPING BY CONTINENT--
SELECT continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE CONTINENT IS NOT NULL 
--WHERE Location like '%states%'--
Group by continent
order by TotalDeathCount DESC


--Global Numbers for each date--
SELECT date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Continent is not null
group by date
order by 1,2

--Global numbers aggregated till the last date--
SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Continent is not null
order by 1,2

--Vaccination Data--
SELECT *
FROM PortfolioProject..CovidVaccinations$

--Joining Tables--
SELECT *
FROM PortfolioProject..CovidDeaths$ cd
JOIN PortfolioProject..CovidVaccinations$ cv
ON cd.location=cv.location and cd.date=cv.date

--Looking at total population vs vaccination--
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM PortfolioProject..CovidDeaths$ cd
JOIN PortfolioProject..CovidVaccinations$ cv
ON cd.location=cv.location and cd.date=cv.date
WHERE cd.continent is not null
order by 2,3

--Rolling calculation of vaccinations--
--Using Windows function and Partition By--
--Using Bigint--
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ cd
JOIN PortfolioProject..CovidVaccinations$ cv
 ON cd.location=cv.location and cd.date=cv.date
WHERE cd.continent is not null
order by 2,3

--Total Population VS  Vaccinations-- (By creating CTE or temporary table)

--Using CTE--
With PopvsVac(continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
  SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ cd
JOIN PortfolioProject..CovidVaccinations$ cv
 ON cd.location=cv.location and cd.date=cv.date
WHERE cd.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using a Temp Table--
DROP TABLE if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
  SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ cd
JOIN PortfolioProject..CovidVaccinations$ cv
 ON cd.location=cv.location and cd.date=cv.date

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentOfPeopleVaccinated
From PercentPopulationVaccinated


--Creating a View to store data for later visualizations--
Create View PercentPopVaccinated as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ cd
JOIN PortfolioProject..CovidVaccinations$ cv
 ON cd.location=cv.location and cd.date=cv.date
WHERE cd.continent is not null


Select *
FROM PercentPopVaccinated