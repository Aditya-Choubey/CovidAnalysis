
Select *
From PortfolioProjects..[Covid Deaths]
where continent is not null
order by 3,4

--Select *
--From PortfolioProjects..[Covid Vaccinations]
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..[Covid Deaths]
where continent is not null
order by 1,2

--Looking at Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as [Death Percentage]
From PortfolioProjects..[Covid Deaths]
where location= 'India'
and continent is not null
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as [Total Cases Percentage]
From PortfolioProjects..[Covid Deaths]
--where location= 'India'
order by 1,2


--Looking at Countries with Highest Infection Rate Compared to Population

Select location, population, MAX(total_cases) as [Highest Infection Count], MAX((total_cases/population))*100 as [Total Cases Percentage]
From PortfolioProjects..[Covid Deaths]
--where location= 'India'
group by location, population
order by [Total Cases Percentage] desc

--    3

Select location, population, date, MAX(total_cases) as [Highest Infection Count], MAX((total_cases/population))*100 as [Total Cases Percentage]
From PortfolioProjects..[Covid Deaths]
--where location= 'India'
group by location, population, date
order by [Total Cases Percentage] desc

--    4



--Showing Countries with Hughest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as [Total Death Count]
From PortfolioProjects..[Covid Deaths]
--where location= 'India'
where continent is not null
group by location
order by [Total Death Count] desc


-- Looking at total death count by continent


Select location ,SUM(Cast(new_deaths as int)) as [Total Death Count]
From PortfolioProjects..[Covid Deaths]
where continent is null
and location not in ('World', 'Upper middle income', 'High income', 'Lower middle income', 'European Union', 'Low income', 'international')
Group by location 
Order by[Total Death Count] desc  

--    2

-- Let's See Highest Death Count By Continent

Select continent, MAX(cast(total_deaths as int)) as [Max Death Count]
From PortfolioProjects..[Covid Deaths]
--where location= 'India'
where continent is not null
group by continent
order by [Max Death Count] desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as [Death Percentage]
From PortfolioProjects..[Covid Deaths]
--where location= 'India'
where continent is not null
order by 1,2
--   1

select *
From PortfolioProjects..[Covid Vaccinations]

-- Joining Both Tables
Select *
From PortfolioProjects..[Covid Deaths] dea
Join PortfolioProjects..[Covid Vaccinations] vac
 On dea.location = vac.location
 And dea.date = vac.date

--Looking at total population Vs Vaccinations

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProjects..[Covid Deaths] dea
Join PortfolioProjects..[Covid Vaccinations] vac
 On dea.location = vac.location
 And dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProjects..[Covid Deaths] dea
Join PortfolioProjects..[Covid Vaccinations] vac
 On dea.location = vac.location
 And dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From Popvsvac


--Temp Table


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

Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProjects..[Covid Deaths] dea
Join PortfolioProjects..[Covid Vaccinations] vac
 On dea.location = vac.location
 And dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProjects..[Covid Deaths] dea
Join PortfolioProjects..[Covid Vaccinations] vac
 On dea.location = vac.location
 And dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
From PercentPopulationVaccinated