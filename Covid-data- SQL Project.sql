Select * 
From PortfolioProject..CovidDeath$
order by 3,4

Select * 
From PortfolioProject..CovidDeath$
where continent is not null
order by 3,4

Select * 
From PortfolioProject..CovidVaccinations$
order by 3,4


--Select Data that going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath$
where continent is not null
order by 1,2


--looking at Total Cases vs Total Deaths

Select location, date, total_cases, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 as DeathPercentage
From PortfolioProject..CovidDeath$
order by 1,2




-- Total Cases vs Total Deaths in United States

Select location, date, total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 as DeathPercentage
From PortfolioProject..CovidDeath$
where location like '%states'
order by 1,2


-- looking at Total cases vs Population

Select location, date, total_cases,population, (cast(total_cases as decimal))/population*100 as CasePercentage
From PortfolioProject..CovidDeath$
where location like '%states'
order by 1,2


-- looking at Countries with Highest infrction rate compared to Population

Select location, population, MAX(cast(total_cases as decimal)) as HighestInfectionCount, Max((cast(total_cases as decimal))/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeath$
where continent is not null
Group by location, population
order by InfectedPopulationPercentage desc


-- Showing countries with the highest death count per population

Select location,Max(cast(total_deaths as int)) as TotalDeathCount, population
From PortfolioProject..CovidDeath$
where continent is not null
Group by location, population
order by TotalDeathCount desc

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
where continent is null
Group by location
order by TotalDeathCount desc


-- break things down by Continent

-- showing the continent with the highest death count as per population

Select continent,Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
where continent is not null
Group by continent
order by TotalDeathCount desc



--Global numbers

Select  date, SUM(new_cases)as TotalCases, SUM(new_deaths) as TotalNewDeaths
From PortfolioProject..CovidDeath$
where continent is not null
Group by date
order by 1,2 


Select SUM(new_cases)as TotalCases, SUM(new_deaths) as TotalNewDeaths
From PortfolioProject..CovidDeath$
where continent is not null


-- Join two tables

Select *
From PortfolioProject..CovidDeath$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total population vs Vaccination

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeath$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3
 

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(decimal,vac.new_vaccinations))Over(Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3
 
 -- Use TEMP Table creation 

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
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(numeric,vac.new_vaccinations))Over(Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated 
From PortfolioProject..CovidDeath$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Order by 2,3
 
Select * ,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Create view to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(numeric,vac.new_vaccinations))Over(Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated 
From PortfolioProject..CovidDeath$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

select * 
from PercentPopulationVaccinated