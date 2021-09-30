Select * 
From da_projects..CovidDeaths
Where continent is not null
order by 3, 4

--Select * 
--From da_projects..CovidVaccinations
--order by 3, 4

--Select data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population 
From da_projects..CovidDeaths
Where continent is not null
order by 1, 2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From da_projects..CovidDeaths
Where Location like 'I%dia'
and continent is not null
order by 1, 2
 
 --Looking at total cases vs population 
 --Shows what percentage of population got covid
 Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulatoionInfected
From da_projects..CovidDeaths
--Where Location like 'I%dia'
Where continent is not null
order by 1, 2

--countries with highest infection rate
Select Location, population, Max(total_cases) as HighestInfectioncount, Max((total_cases/population))*100 as PercentPopulatoionInfected
From da_projects..CovidDeaths
--Where Location like 'I%dia'
Where continent is not null
Group by Location, population 
order by PercentPopulatoionInfected desc


--Showing countries with highest desth count per population

Select Location, population, Max(total_cases) as HighestInfectioncount, Max((total_cases/population))*100 as PercentPopulatoionInfected
From da_projects..CovidDeaths
--Where Location like 'I%dia'
Where continent is not null
Group by Location, population 
order by PercentPopulatoionInfected desc


--Showingcountries with highest death count per polpulation 

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From da_projects..CovidDeaths
--Where Location like 'I%dia'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

 
 --showing continents with highest count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From da_projects..CovidDeaths
--Where Location like 'I%dia'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--global numbers

Select SUM(new_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From da_projects..CovidDeaths
--Where Location like 'I%dia'
where continent is not null
--group by date
order by 1, 2
 
 --looking at total population vs vaccination

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int, vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
--instead of cast convert is used or both can be used
from da_projects..CovidDeaths dea
join da_projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like 'India'
order by 2, 3


--USE CTE

with PopvsVac (Continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int, vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
--instead of cast convert is used or both can be used
from da_projects..CovidDeaths dea
join da_projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like 'India'
--order by 2, 3
) 
select *,(RollingPeopleVaccinated/population)*100 
from PopvsVac



--temp table

drop table if exists #PercentPopulationVaccinated
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
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations))over (partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
from da_projects..CovidDeaths dea
join da_projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--and dea.location like 'India'
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create View PercentPopulationVaccinated
as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations))over (partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
from da_projects..CovidDeaths dea
join da_projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated