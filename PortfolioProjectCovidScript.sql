
--select data from CovidDeaths table
select location, date, total_cases, new_cases, total_deaths, population	 
from PortfolioProjectCovid..CovidDeaths
order by 1,2


--total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage	 
from PortfolioProjectCovid..CovidDeaths
where location like '%egypt%'
order by 1,2

--total cases vs population
--shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PopulationCovidPercentage	 
from PortfolioProjectCovid..CovidDeaths
--where location like '%egypt%'
order by 1,2


--countries with highest infectin rate compared to population 
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationCovidPercentage		 
from PortfolioProjectCovid..CovidDeaths
--where location like '%egypt%'
group by location, population 
order by PopulationCovidPercentage desc


--countries with highest death count per population 
select location, MAX(cast(total_deaths as int)) as TotalDaathCount
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by location 
order by TotalDaathCount desc

  
--continents with highest death count
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovid..CovidDeaths
where continent is null
group by location 
order by TotalDeathCount desc


--Global deaths and deaths percentage 
select sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_death, 
	Sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where continent is not null


--total population vs vaccinations
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location,
    death.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths death
join PortfolioProjectCovid..CovidVaccinations vacc  
on death.location = vacc.location and death.date = vacc.date 
where death.continent is not null
order by 2, 3



with PopulationvsVaccination(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
 sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by 
 death.location, death.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths death
join PortfolioProjectCovid..CovidVaccinations vacc  
on death.location = vacc.location and death.date = vacc.date 
where death.continent is not null 
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopulationvsVaccination


--temp table 
Drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location 
order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths death
join PortfolioProjectCovid..CovidVaccinations vacc  
on death.location = vacc.location and death.date = vacc.date 
where death.continent is not null 

select *, (RollingPeopleVaccinated/population)*100 
from PercentPopulationVaccinated



create view vw_PercentPopulationVaccinated
as
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location,
    death.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths death
join PortfolioProjectCovid..CovidVaccinations vacc  
on death.location = vacc.location and death.date = vacc.date 
where death.continent is not null

select * from vw_PercentPopulationVaccinated

