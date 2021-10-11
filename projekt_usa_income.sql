-- zarobki

create table income as
select
	pr.county,
	pr.state ,
	pr.candidate,
	pr.party,
	pr.votes,
	pr.fraction_votes,
	cf."INC910213" as per_capita,
	cf."INC110213" as median_income,
	cf."PVY020213" as below_poverty
from county_facts cf 
join primary_results pr on cf.fips = pr.fips

SELECT 
	max(i.per_capita) as max_pc,
	min(i.per_capita),
	(max(i.per_capita) - min(i.per_capita)) / 4 as interval_pc,
	max(i.median_income) as max_b,
	min(i.median_income),
	(max(i.median_income) - min(i.median_income)) / 4 as interval_b
from income i 

--dochód na osobê
SELECT 
	distinct(i.candidate),
	i.party,
	sum(i.votes) over (partition by i.party) as sum_votes_party,
	sum(i.votes) over (partition by i.candidate) as sum_votes_candidate
from income i 
where i.per_capita between 8768.0 and 22200.5
order by sum_votes_candidate desc

SELECT 
	distinct(i.candidate),
	i.party,
	sum(i.votes) over (partition by i.party) as sum_votes_party,
	sum(i.votes) over (partition by i.candidate) as sum_votes_candidate
from income i 
where i.per_capita between 22200.5 and 35633.0
order by sum_votes_candidate desc

SELECT 
	distinct(i.candidate),
	i.party,
	sum(i.votes) over (partition by i.party) as sum_votes_party,
	sum(i.votes) over (partition by i.candidate) as sum_votes_candidate
from income i 
where i.per_capita between 35633.0 and 49065.5
order by sum_votes_candidate desc

SELECT 
	distinct(i.candidate),
	i.party,
	sum(i.votes) over (partition by i.party) as sum_votes_party,
	sum(i.votes) over (partition by i.candidate) as sum_votes_candidate
from income i 
where i.per_capita between 49065.5 and 62498.0
order by sum_votes_candidate desc

select -- w których stanach jest najmniejszy dochód na osobê
	cf.area_name ,	
	cf."INC910213" 
from county_facts cf 
where cf.fips like '%000' and cf."INC910213" < 25000
order by cf."INC910213" asc

select -- w których stanach jest najwiêkszy dochód na osobê
	cf.area_name ,	
	cf."INC910213" 
from county_facts cf 
where cf.fips like '%000' and cf."INC910213" > 30000
order by cf."INC910213" desc






--œredni przychód na domostwo
SELECT 
	distinct(i.candidate),
	i.party,
	sum(i.votes) over (partition by i.party) as sum_votes_party,
	sum(i.votes) over (partition by i.candidate) as sum_votes_candidate
from income i 
where i.median_income between 19986.0 and 45549.0
order by sum_votes_candidate desc

SELECT 
	distinct(i.candidate),
	i.party,
	sum(i.votes) over (partition by i.party) as sum_votes_party,
	sum(i.votes) over (partition by i.candidate) as sum_votes_candidate
from income i 
where i.median_income between 45549.0 and 71112.0
order by sum_votes_candidate desc

SELECT 
	distinct(i.candidate),
	i.party,
	sum(i.votes) over (partition by i.party) as sum_votes_party,
	sum(i.votes) over (partition by i.candidate) as sum_votes_candidate
from income i 
where i.median_income between 71112.0 and 96675.0 
order by sum_votes_candidate desc

SELECT 
	distinct(i.candidate),
	i.party,
	sum(i.votes) over (partition by i.party) as sum_votes_party,
	sum(i.votes) over (partition by i.candidate) as sum_votes_candidate
from income i 
where i.median_income between 96675.0 and 122238.0
order by sum_votes_candidate desc

select -- w których stanach jest najmniejszy dochód na domostwo
	cf.area_name ,	
	cf."INC110213" 
from county_facts cf 
where cf.fips like '%000' and cf."INC110213" < 45000
order by cf."INC110213" asc

select -- w których stanach jest najwiêkszy dochód na domostwo
	cf.area_name ,	
	cf."INC110213" 
from county_facts cf 
where cf.fips like '%000' and cf."INC110213" > 60000
order by cf."INC110213" desc






-- osoby ¿yj¹ce poni¿ej poziomu ubóstwa
SELECT 
	max(i.below_poverty) as max_bp,
	min(i.below_poverty),
	(max(i.below_poverty) - min(i.below_poverty)) / 4 as interval_bp
from income i 
where i.party is not null

SELECT 
	distinct(i.candidate),
	i.party,
	sum(i.votes) over (partition by i.party) as sum_votes_party,
	sum(i.votes) over (partition by i.candidate) as sum_votes_candidate
from income i 
where i.below_poverty between 40.1 and 53.3
order by sum_votes_candidate desc

SELECT 
	distinct(i.candidate),
	i.party,
	sum(i.votes) over (partition by i.party) as sum_votes_party,
	sum(i.votes) over (partition by i.candidate) as sum_votes_candidate
from income i 
where i.below_poverty between 0.8 and 14.0
order by sum_votes_candidate desc

select -- w których stanach jest najwiêcej osób ¿yj¹cych poni¿ej poziomu ubóstwa
	cf.area_name ,	
	cf."PVY020213" 
from county_facts cf 
where cf.fips like '%000' and cf."PVY020213" > 18.0
order by cf."PVY020213" desc

select -- w których stanach jest najmniej osób ¿yj¹cych poni¿ej poziomu ubóstwa
	cf.area_name ,	
	cf."PVY020213" 
from county_facts cf 
where cf.fips like '%000' and cf."PVY020213" < 11.5
order by cf."PVY020213" asc
