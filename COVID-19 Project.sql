Select *
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations$
--Order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if infected with COVID-19 in specific country

Select Location, Date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS MortalityPercentage
FROM PortfolioProject..CovidDeaths$
Where Location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population that are infected with COVID-19

Select Location, Date, total_cases, population,(total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths$
Where Location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, MAX(total_cases) AS HighestInfectionCount, population, MAX(total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths$
Group by Location, Population
order by InfectedPercentage Desc

-- Looking at Countries with Highest Death Count compared to population

Select Location, MAX(cast(total_cases as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount Desc

-- Let's break things down by continent, location

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_cases as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
Group by continent
order by TotalDeathCount Desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where Location like '%states%'
WHERE continent is not null
--Group by date
order by 1,2 

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USING CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select *
From PercentPopulationVaccinated
