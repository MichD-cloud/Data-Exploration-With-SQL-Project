select *
from Project_Covid..CovidDeaths
where continent is not null
order by 3,4

select *
from Project_Covid..CovidVaccinations
order by 3,4

--Data For use 

select location, date,total_cases, total_deaths, new_cases, total_deaths, population
from Project_Covid..CovidDeaths
order by 1,2

--Total cases Vs Totaal deaths
--Shows likely of death due to covid infection

select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_death
from Project_Covid..CovidDeaths
where location = 'Kenya'
order by 1,2

--Total cases Vs Population
--Shows percentage of population that contracted covid

select location, date,total_cases, population, (total_cases/population)*100 as percentage_death
from Project_Covid..CovidDeaths
where location = 'Kenya'
order by 1,2

--country with highest infection rate compared to population


select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as percentPopulationInfected
from Project_Covid..CovidDeaths
--where location = 'Kenya'
group by location, population
order by percentPopulationInfected desc



--Country with highest death count per population


select location, max(cast(total_deaths as int)) as TotalDeathCount
from Project_Covid..CovidDeaths
--where location = 'Kenya'
where continent is not null
group by location
order by TotalDeathCount desc


--comparison by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Project_Covid..CovidDeaths
--where location = 'Kenya'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers

select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int))as total_deaths
from Project_Covid..CovidDeaths
--where location = 'Kenya'
where continent is not null
--group by continent
order by 1,2



--Comparing Total Population and Vaccination


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Project_Covid..CovidDeaths dea
join Project_Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3





select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Project_Covid..CovidDeaths dea
join Project_Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--percent of pepole vaccinated 


with popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Project_Covid..CovidDeaths dea
join Project_Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinated/population)*100
from popvsvac




--TEMP TABLE


Drop table if exists PercentePopulationVaccinated
create table PercentePopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
insert into PercentePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Project_Covid..CovidDeaths dea
join Project_Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rolling_people_vaccinated/population)*100
from PercentePopulationVaccinated


--creating a view for use in visualization 

create view Percente_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Project_Covid..CovidDeaths dea
join Project_Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
