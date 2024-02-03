--select *
--from CovidDeaths
--order by 3,4;

--select *
--from CovidVaccinations
--order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project_Covid.dbo.CovidDeaths
where continent is not null
order by 1,2;

--- Total Cases vs Total Deaths ---
--- shows likelihood of dying if you contract covid in your country ---

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project_Covid.dbo.CovidDeaths
where location like '%States%' and
continent is not null
order by 1,2;


--- looking at Total cases vs Population ---
--- shows what percentage of population got coivd ---

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from Portfolio_Project_Covid.dbo.CovidDeaths
where location like '%States%' and
continent is not null
order by 1,2;


--- looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from Portfolio_Project_Covid.dbo.CovidDeaths
---where location like '%States%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc;


--- showing Countries with Highest Death Count Per Population ----

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project_Covid.dbo.CovidDeaths
---where location like '%States%'
where continent is not null
group by location
order by TotalDeathCount desc;



-- Let's bring down by continent ---

-- Showing the continents with the highest death count per population ---

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project_Covid.dbo.CovidDeaths
---where location like '%States%'
where continent is not  null
group by continent
order by TotalDeathCount desc;


--- Global Numbers ---

select  sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
from Portfolio_Project_Covid.dbo.CovidDeaths
-- where location like '%States%' 
where continent is not null
--group by date
order by 1,2;


select date, sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
from Portfolio_Project_Covid.dbo.CovidDeaths
-- where location like '%States%' 
where continent is not null
group by date
order by 1,2;


--- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
---(RollingPeopleVaccinated/population)*100
from Portfolio_Project_Covid.dbo.CovidDeaths dea
join Portfolio_Project_Covid.dbo.CovidVaccinations vac
	on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
		order by 2,3;


---Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
from Portfolio_Project_Covid.dbo.CovidDeaths dea
join Portfolio_Project_Covid.dbo.CovidVaccinations vac
	on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
		--order by 2,3
		)
select *, (RollingPeopleVaccinated)/population*100
from PopvsVac;



--- Temp Table ---

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated 
(
continent nvarchar (255),
location nvarchar(255), 
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
from Portfolio_Project_Covid.dbo.CovidDeaths dea
join Portfolio_Project_Covid.dbo.CovidVaccinations vac
	on dea.location = vac.location
		and dea.date = vac.date
	--where dea.continent is not null
		--order by 2,3
	

select *, (RollingPeopleVaccinated)/population*100
from #PercentPopulationVaccinated
;


--- Creating view to store data for later visualizations


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
from Portfolio_Project_Covid.dbo.CovidDeaths dea
join Portfolio_Project_Covid.dbo.CovidVaccinations vac
	on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
		--order by 2,3

select * from PercentPopulationVaccinated;





















