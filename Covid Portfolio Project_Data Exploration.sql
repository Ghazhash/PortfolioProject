Select*
from Portfolioproject..CovidDeaths$
where continent is not null
order by 3,4

--select*
--from Portfolioproject..CovidVaccinations$
--order by 3,4

--select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths
from Portfolioproject..CovidDeaths$
order by 1, 2

--looking at total cases vs total deaths
--shows likelihood of ding if you contract covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from Portfolioproject..CovidDeaths$
where location like '%States%'
order by 1, 2

--looking at total cases vs population

Select location, date, total_cases, population, total_deaths, (total_deaths/population)*100 as Deathpercentage
from Portfolioproject..CovidDeaths$
--where location like '%States%'
order by 1, 2

--looking at countries with highest infection rate compared to population
Select location, population, max(total_cases) as HighestInfectionCount,  (max((total_cases/population))*100) as PercentPopulationInfected
from Portfolioproject..CovidDeaths$
--where location like '%States%'
group by population, location
order by PercentPopulationInfected desc

--showing countries with highest death count per population
Select location, max(total_deaths) as TotalDeathCount
from Portfolioproject..CovidDeaths$
--where location like '%States%'
group by location
order by TotalDeathCount desc

--break things down by continent
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths$
--where location like '%States%'
where continent is not null
group by continent
order by TotalDeathCount desc


Select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths$
--where location like '%States%'
where continent is null
group by location
order by TotalDeathCount desc




--showing countries with highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths$
--where location like '%States%'
where continent is not null
group by location
order by TotalDeathCount desc


---- Let's look at Global Values

Select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100  as Deathpercentage
from Portfolioproject..CovidDeaths$
--where location like '%States%'
where continent is not null
group by date
order by 1, 2

--looking at total population vs vaccination

select*
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
     on dea.location =vac.location
	 and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
     on dea.location =vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
     on dea.location =vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte

with PopvsVac (continent, location ,date, population,new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
     on dea.location =vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select* ,(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
from PopvsVac



--temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert  into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
     on dea.location =vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


DROP View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
     on dea.location =vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated

DROP VIEW PercentPopulationVaccinated;



