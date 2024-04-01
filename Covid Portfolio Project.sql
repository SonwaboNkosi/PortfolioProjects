
Select *
From PortfolioProject..CovidDeaths
WHERE continent is not null
Order By 3, 4;


--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3, 4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
WHERE continent is not null
Order By 1,2;


--Looking at Total Cases  vs Total Deaths 
-- Shows likelihood of dying if you contract covid in South Afria 
Select location, date, total_cases, total_deaths, (CONVERT(Float, total_deaths)/CONVERT(FLOAT, total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location = 'South africa'
and continent is not null
Order By 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 
Select location, date, population, total_cases, (CONVERT(Float, total_cases)/ CONVERT(FLOAT,population))*100 as CovidPercentage
From PortfolioProject..CovidDeaths
WHERE location = 'South africa'
and continent is not null
Order By 1,2;


--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectionCount, Max(CONVERT(Float, total_cases)/ CONVERT(FLOAT,population))*100 as CovidPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group By Location, population
Order By CovidPercentage DESC

--Showing countries with highest death count per population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group By Location
Order By TotalDeathCount DESC


--Let's Break Things Down By Continent
--Showing Contintents with the highest death count per population
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is null and location != 'High Income' and location !=  'Upper middle income' and location != 'Lower middle income' and location != 'Low income'
Group By location
Order By TotalDeathCount DESC


-- Let's Break Things Down By Income
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE location = 'High Income' or location =  'Upper middle income' or location = 'Lower middle income' or location = 'Low income'
Group By location
Order By TotalDeathCount DESC



--Global Numbers 


--Total deaths and cases each day world wide 
Select date, SUM(total_cases) as total_cases, SUM(total_deaths) as total_deaths, Convert(Float, convert(Float, SUM(total_deaths))/ Convert(Float, SUM(total_cases)) * 100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By date
Order By 1,2;


--Total cases and deaths to date globally
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, Convert(Float, convert(Float, SUM(new_deaths))/ Convert(Float, SUM(new_cases)) * 100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order By 1,2;



--Looking at Total Population vs Vaccinated 

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
,SUM(CONVERT(BIGINT, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths
Join PortfolioProject..CovidVaccinations as vacc
	on deaths.location = vacc.location
	and deaths.date = vacc.date
Where deaths.continent is not null
Order by 2,3


--Using CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
,SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location order by deaths.location, 
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths
Join PortfolioProject..CovidVaccinations as vacc
	on deaths.location = vacc.location
	and deaths.date = vacc.date
Where deaths.continent is not null 
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopVsVac


--Temp Table

Drop Table if Exists #PercenPopulationVaccinated
Create Table #PercenPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercenPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
,SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location order by deaths.location, 
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths
Join PortfolioProject..CovidVaccinations as vacc
	on deaths.location = vacc.location
	and deaths.date = vacc.date
Where deaths.continent is not null 
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercenPopulationVaccinated


--Creating view to store data for later  Visualisations

Create View PercenPopulationVaccin as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
,SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location order by deaths.location, 
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths
Join PortfolioProject..CovidVaccinations as vacc
	on deaths.location = vacc.location
	and deaths.date = vacc.date
Where deaths.continent is not null 
--order by 2, 3

Select *
From PercenPopulationVaccin