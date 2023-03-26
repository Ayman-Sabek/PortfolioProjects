Select *
From PortfolioProject..CovidDeaths
order by 1,2 


-- Select Data will be used
Select Location, date, total_cases, new_cases, population
From PortfolioProject..CovidDeaths
order by 1,2

 --Looking at Total Cases vs Total Deaths
 --Shows likelyhood of dying by contracting covid in the US

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population 
--Shows percentage of populatio got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


 --Looking at Countries w/Highest Infection Rate Compared to Population

Select Location, population, MAX (total_cases) as HighestIneftionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



 --Showing Countries w/ Highest Death Count p/ Population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where total_deaths is not null
Group by Location, Population
order by TotalDeathCount desc



 --Covid Break by Continent
 --Showing continents w/Highest Death Count

Select continent, MAX (cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc 


 --Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



 --TEMP TABLE

DROP Table if exists #PercentPoplulationVaccinated
Create Table #PercentPoplulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPoplulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPoplulationVaccinated



 --Creating View to store data for later visualizations

Create View PercentPoplulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



----Select *
----From PercentPoplulationVaccinated