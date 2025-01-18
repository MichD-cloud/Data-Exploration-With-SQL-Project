## Covid Data Analysis

### Project Overview

 This project aims to analyze Covid data to gain deep insights and understand the Impact of covid in various regions.  Exploration using SQL and visualization using Tableau 

### Data Source

 The primary data is covid-deaths data that contains data on covid deaths and vaccinations.

### Data formatting and cleaning

 -Did data formatting using Microsoft Excel
 
 -Created two csv file “covid_deaths.csv” and “covid_vaccinations.csv”

 ### Data Analysis
  
  --Data for use
  ```sql
  select location, date,total_cases, total_deaths, new_cases, total_deaths, 
  population
  from Project_Covid..CovidDeaths
  order by 1,2
  ```
--Total cases Vs Total deaths
-Shows likely of death due to covid infection
```sql
select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_death
from Project_Covid..CovidDeaths
where location = 'Kenya'
order by 1,2
```
--Total cases Vs Population
-Shows percentage of population that contracted covid
```sql
select location, date,total_cases, population, (total_cases/population)*100 as percentage_death
from Project_Covid..CovidDeaths
where location = 'Kenya'
order by 1,2
```
--country with highest infection rate compared to population
```sql
select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as percentPopulationInfected
from Project_Covid..CovidDeaths
--where location = 'Kenya'
group by location, population
order by percentPopulationInfected desc
```
--Country with highest death count per population
```sql
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Project_Covid..CovidDeaths
--where location = 'Kenya'
where continent is not null
group by location
order by TotalDeathCount desc
```
--comparison by continent
```sql
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Project_Covid..CovidDeaths
--where location = 'Kenya'
where continent is not null
group by continent
order by TotalDeathCount desc
```
--Comparing Total Population and Vaccination
```sql
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Project_Covid..CovidDeaths dea
join Project_Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
```
```sql
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Project_Covid..CovidDeaths dea
join Project_Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
```
--percent of pepole vaccinated 
```sql
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
```
--creating Temp table
```sql
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
```
--creating a view for use in visualization
```sql
create view Percente_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Project_Covid..CovidDeaths dea
join Project_Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
```

