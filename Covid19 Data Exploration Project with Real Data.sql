SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
where continent IS NOT NULL
order by 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidDeaths
--order by 3,4

--SELECTING THE DATA TO BE USED 
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.CovidDeaths
ORDER by 1,2


--Let's consider the Total Cases verse the Total Deaths
--this also shows the percentage possiblity of death like on gets covid in all region

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases*100))AS DeathPerPopulation
FROM PortfolioProject.dbo.CovidDeaths
ORDER by 1,2


SELECT  SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
where continent is not null
--group by date
ORDER by 1,2



SELECT *
FROM PortfolioProject..CovidVaccinations



--lets look at specific countries like USA, then add CANADA, GHANA AND ZIMBABWE to the list 

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases*100))AS DeathPerPopulation
FROM PortfolioProject.dbo.CovidDeaths
WHERE location IN ( 'United States', 'Canada', 'Ghana', 'Zimbabwe' )
ORDER by 1,2 ASC


--Looking at the total cases against the population 
--shows the percenatge of people that got covid in Canada and the states 
SELECT location, date,population ,total_cases,  ((total_cases/population*100))AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location IN ( 'United States', 'Canada' )
ORDER by 1,2 ASC


--Looking at Countries with the highest Infection rate compare to the population 
SELECT Location, Population ,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location IN ( 'United States', 'Canada' )
GROUP BY Location, Population
ORDER by PercentPopulationInfected DESC

--Looking into the countries with the heightest death count 
SELECT Location, MAX(cast (total_deaths as int)) AS TotalDeathCount /*totaldeaths needs to be casted as an intger to correct an error with is datatype*/  
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location IN ( 'United States', 'Canada' )
WHERE continent IS NOT NULL
GROUP BY Location
ORDER by TotalDeathCount DESC



--LETS BREAK THINGS DOWN INTO CONTINENTS 
SELECT location, MAX(cast (total_deaths as int)) AS TotalDeathCount /*totaldeaths needs to be casted as an intger to correct an error with is datatype*/  
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location IN ( 'United States', 'Canada' )
WHERE continent IS NULL
GROUP BY location
ORDER by TotalDeathCount DESC

--OR 

SELECT continent, MAX(cast (total_deaths as int)) AS TotalDeathCount /*totaldeaths needs to be casted as an intger to correct an error with is datatype*/  
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location IN ( 'United States', 'Canada' )
WHERE continent IS NOT NULL
GROUP BY continent
ORDER by TotalDeathCount DESC


--SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT per population  

SELECT continent,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER by TotalDeathCount DESC 
 


 -----GLOBAL NUMBERS 
 SELECT date,  ((total_deaths/total_cases*100))AS DeathPerPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER by 1,2 ASC

SELECT date,SUM (new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like %state%
Where continent is not null
GROUP BY date
ORDER BY 1,2

--what if we want to know for the total cases and toal deaths across the world 
SELECT SUM (new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like %state%
Where continent is not null
--GROUP BY date
ORDER BY 1,2



SELECT date, location 
FROM PortfolioProject..CovidDeaths

SELECT date, location 
FROM PortfolioProject..CovidVaccinations



--MOVING TO THE COVID VACCINATION DATABASE 
--first lets join both tables
SELECT *
FROM PortfolioProject..CovidDeaths dea
LEFT JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
  AND  dea.date = vac.date

  --or 
 
 SELECT cd.*, cv.*
FROM PortfolioProject..CovidDeaths cd
LEFT JOIN  PortfolioProject..CovidVaccinations cv
ON cd.location = cv.location
  AND  cd.date = cv.date


--looking at the total population verse vanccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
LEFT JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
   AND  dea.date = vac.date
   where dea.continent is not NULL
   ORDER BY 2,3


--USING A CTE as we cant use the just named colunm rollingpeoplevaccinated
  WITH PopVsVac(continent, location,  date, population, new_vaccinations, RollingPeopleVaccinated)
  as 
 (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
   AND  dea.date = vac.date
   where dea.continent is not NULL
   --ORDER BY 2,3
   )

   SELECT *, (RollingPeopleVaccinated/population)*100
   FROM PopVsVac



   --TEMP TABLE 
   DROP TABLE if exists #PercentPopulationVaccinated
   Create Table #PercentPopulationVaccinated
   (continent nvarchar(255),
   location nvarchar(255),
   date datetime,
   population numeric,
   new_vaccinations numeric,
   RollingPeopleVaccinated numeric
   )
   INSERT INTO #PercentPopulationVaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
   AND  dea.date = vac.date
   --where dea.continent is not NULL
   --ORDER BY 2,3

   SELECT *, (RollingPeopleVaccinated/population)*100
   FROM #PercentPopulationVaccinated





   --Creating View to Store data for later visualizations
   
   Create View PercentPopulationVaccinated as
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND  dea.date = vac.date
   where dea.continent is not NULL
   --ORDER BY 2,3


   SELECT *
   FROM PercentPopulationVaccinated
