Use PortfolioProject
Select *
from PortfolioProject..owidcoviddata
where continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..owidcoviddata
where continent is not null
order by 1,2


--Looking at Total_cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (cast(total_deaths as decimal)/total_cases)*100 as DeathPercentage
from PortfolioProject..owidcoviddata
Where location like '%states%'
and continent is not null
order by 1,2

Select Location, date, total_cases,total_deaths, (cast(total_deaths as decimal)/total_cases)*100 as DeathPercentage
from PortfolioProject..owidcoviddata
Where location like '%Canada%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, total_cases,population, (cast(total_cases as decimal)/population)*100 as PercentagePopulationInfected
from PortfolioProject..owidcoviddata
Where location like '%Canada%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location,population,MAX (total_cases) as HighestInfectionCount, MAX((cast(total_cases as decimal)/population))*100 as PercentagePopulationInfected
from PortfolioProject..owidcoviddata
--Where location like '%Canada%'
Group by Location, Population
order by PercentagePopulationInfected desc


--Showing Countries with Highest Death Count per Population
Select Location,MAX(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..owidcoviddata
--Where location like '%Canada%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select location,MAX(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..owidcoviddata
--Where location like '%Canada%'
where continent is null
Group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
Select continent,MAX(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..owidcoviddata
--Where location like '%Canada%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Looking at this data from viewpoint that I'm going to visualize it: so look at global numbers
--Basically everything up replace with select continent and group by continent. You can do drilling down when you have layers which is basically opening countries in Africa 


-- GLOBAL NUMBERS
-- Doing this will give you error because we can't group by date since we are looking at multiple things
Select date, total_cases,total_deaths, (cast(total_deaths as decimal)/total_cases)*100 as DeathPercentage
from PortfolioProject..owidcoviddata
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

--You can't do this because it is a aggregate function in an aggregate function
Select date, SUM(MAX(new_cases)--total_deaths, (cast(total_deaths as decimal)/total_cases)*100 as DeathPercentage
from PortfolioProject..owidcoviddata
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

--This will give total across the world each day because we aren't filtering by continent or anything, just date
Select date, SUM(new_cases)--total_deaths, (cast(total_deaths as decimal)/total_cases)*100 as DeathPercentage
from PortfolioProject..owidcoviddata
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

-- It will give error because the new cases is a float but the new deaths are nvarchar, so we cast as int below
Select date, SUM(new_cases), SUM(new deaths)--total_deaths, (cast(total_deaths as decimal)/total_cases)*100 as DeathPercentage
from PortfolioProject..owidcoviddata
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

--Cast as integer
Select date, SUM(new_cases), SUM(CAST(new_deaths as int)) as DeathPercentage
from PortfolioProject..owidcoviddata
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

Select date, SUM(CAST(total_cases as int)), SUM(CAST(total_deaths as int)) as DeathPercentage
from PortfolioProject..owidcoviddata
--Where location like '%states%'
where continent is not null
group by date
order by 1,2


--Death percentage across the world per day
Select date, SUM(new_cases)as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..owidcoviddata
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

----Death percentage and total cases across the world in total
Select SUM(new_cases)as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..owidcoviddata
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Lets join our two tables (join on location and dates
Select*
from PortfolioProject..owidcoviddata dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date

--Looking at Total Population vs Vaccinations (new vaccinations per day). You can't just write date, it will give error because they both have it
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..owidcoviddata dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 1,2,3

--Sum of new vaccinations by location
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.date)
from PortfolioProject..owidcoviddata dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

--OR
--Percentage of people vaccinated against the population
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
---(RollingPeopleVaccinated/population)*100
from PortfolioProject..owidcoviddata dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopulationvsVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
---(RollingPeopleVaccinated/population)*100
from PortfolioProject..owidcoviddata dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopulationvsVaccination



--TEMP TABLE


Create Table #PercentPopulationVaccinated
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
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
---(RollingPeopleVaccinated/population)*100
from PortfolioProject..owidcoviddata dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated


--If you would like to change something, comment where continent is notnull out. We will get error, so how do we get around it, WE WILL DROP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
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
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
---(RollingPeopleVaccinated/population)*100
from PortfolioProject..owidcoviddata dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
---(RollingPeopleVaccinated/population)*100
from PortfolioProject..owidcoviddata dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *
From #PercentPopulationVaccinated