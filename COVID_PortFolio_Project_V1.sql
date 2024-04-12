--Case to death ratio by Country
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)* 100 
AS DeathPercentage FROM CovidDeaths
where continent is not null
ORDER BY location, date


--Cases to Population Ratio
SELECT 
	location, 
	date, 
	population,
	total_cases, 
	(total_cases
	/population)* 100 
AS CasePercentage FROM CovidDeaths
where continent is not null
ORDER BY location, date

--country with highest infection rate

SELECT 
	location,  
	population,
	Max(total_cases) Highest_Covid_Case, 
	Max((total_cases
	/population)) * 100
AS Highest_Case_Percentage FROM CovidDeaths
where continent is not null
GROUP BY location, population
ORDER BY Highest_Case_Percentage DESC

--countries with the highest death rate
select location, cast(max(total_deaths) as int) as MaxDeath from CovidDeaths
where continent is not null
group by location
order by MaxDeath desc

--continent with the highest death rate
select continent, cast(max(total_deaths) as int) as Max_Death from CovidDeaths
where continent is not null
group by continent
order by Max_Death desc

--Global numbers
SELECT
	
	sum(cast(new_cases as int)) TotalCases,
	sum(cast(new_deaths as int)) TotalDeaths,
	sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 
	AS DeathPercentage
 FROM CovidDeaths
where continent is not null

--Total Population VS Vaccination
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(bigint, CV.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as RollingPpleVacc
from CovidDeaths CD
join CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
order by CD.location, CD.date

--Using CTE

WITH PopVsVaccPercent as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(int, CV.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as RollingPpleVacc
from CovidDeaths CD
join CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
--order by CD.location, CD.date
)
Select *, (RollingPpleVacc/population * 100) as PercentVaccPerLoc from PopVsVaccPercent

--Temp Tables
drop table if exists #Percent_Vaccinated
create table #Percent_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPPleVacc numeric
)

insert into #Percent_Vaccinated
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(numeric, CV.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as RollingPpleVacc
from CovidDeaths CD
join CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
order by CD.location, CD.date
Select *, (RollingPpleVacc/population * 100) as PercentVaccPerLoc from #Percent_Vaccinated

--Creating view to store data for later visualization

create view Continent_With_Highest_Death_Rate as
select continent, cast(max(total_deaths) as int) as Max_Death from CovidDeaths
where continent is not null
group by continent
--order by Max_Death desc