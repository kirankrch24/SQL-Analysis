
-- Just have a look at CovidDeaths table in Covid database
select *
from [covid].[dbo].[CovidDeaths]
where continent is not null
order by 3,4


-- Looking at Total Cases VS Total Cases

SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
  FROM [covid].[dbo].[CovidDeaths]
  where location like '%kingdom%' 
  order by 1,2


  -- Looking at Total cases VS Population
  -- Shows what percentage of population got covid

  SELECT location, date,population, total_cases, (total_cases/population)*100 as Percent_population_infected
  FROM [covid].[dbo].[CovidDeaths]
  where continent is not null
  --where location like '%kingdom%'
  order by 1,2


  -- Looking at countries with highest infection rate compared to Population
  
  SELECT location,population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as Max_population_infected
  FROM [covid].[dbo].[CovidDeaths]
  --where location like '%kingdom%'
  where continent is not null
  group by location,population
  order by Max_population_infected desc




 -- Showing countries with highest death count per population

  SELECT location, max(cast(total_deaths as int)) as total_death_count
  FROM [covid].[dbo].[CovidDeaths]
  --where location like '%kingdom%'
  where continent is not null
  group by location
  order by total_death_count desc


-- Let's break things down by continent

  SELECT location, max(cast(total_deaths as int)) as total_death_count
  FROM [covid].[dbo].[CovidDeaths]
  --where location like '%kingdom%'
  where continent is null
  group by location
  order by total_death_count desc


 -- Global numbers by date

 Select date,sum(new_cases) as New_Cases, sum(cast(new_deaths as int)) as New_Death , sum(cast(new_deaths as int))/sum(new_cases)*100 as Precentage_Death
 FROM [covid].[dbo].[CovidDeaths]
 where continent is not null
 group by date
 order by 1,2


 -- Global numbers in Total 

 Select sum(new_cases) as New_Cases, sum(cast(new_deaths as int)) as New_Death , sum(cast(new_deaths as int))/sum(new_cases)*100 as Precentage_Death
 FROM [covid].[dbo].[CovidDeaths]
 where continent is not null
 --group by date
 order by 1,2


 -- Covid Vaccination just have look

 select *
 from [covid].[dbo].[CovidVaccinations]



 -- Now joing both the tables Covid Deaths and Covid Vaccinations

 select * 
 from covid..CovidDeaths dea
 join covid..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date


 -- Looking at Total Population VS Vaccinations
 
 with popvsvac ( continent, location, date, population,new_vaccinations ,Rollingpeoplevaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
-- , (Rollingpeoplevaccinated/population)*100
 from covid..CovidDeaths dea
 join covid..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )

select *,(Rollingpeoplevaccinated/population)*100
from popvsvac




--  Temp Table 

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
-- , (Rollingpeoplevaccinated/population)*100
 from covid..CovidDeaths dea
 join covid..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 
select *,(Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated



-- Create view to store data data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
-- , (Rollingpeoplevaccinated/population)*100
 from covid..CovidDeaths dea
 join covid..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3


 select * 
 from PercentPopulationVaccinated