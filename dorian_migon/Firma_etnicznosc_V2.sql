select * from county_facts cf 
select * from primary_results pr 


-- Czy glosy sa zalezne od firmy

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
order by sum_votes_candidate desc

create table firmy as
select
	pr.state, 
	pr.county,	
	pr.candidate,
	pr.party,
	pr.votes,
	pr.fraction_votes,
	pr.flips,
	cf."BZA010213" as private_nonfarm_establishments,
	cf."BZA110213" as private_nonfarm_employment,
	cf."BZA115213" as private_nonfarm_employment_change,
	cf."NES010213" as nonemployer_establishments,
	cf."SBO001207" as total_number_of_firms,
	cf."SBO315207" as black_owned_firms,
	cf."SBO115207" as american_indian_alaska_native_owned_firms,
	cf."SBO215207" as asian_owned_firms,
	cf."SBO515207" as native_hawaiian_owned_firms,
	cf."SBO415207" as hispanic_owned_firms,
	cf."SBO015207" as women_owned_firms
from county_facts cf 
inner join primary_results pr on cf.fips = pr.fips 


--reczne przedzialy dla etnicznosci (populacje sa tak male, ze kwartyle nie maja zastosowania)

SELECT 
	round(max(f.black_owned_firms)::numeric,1) as max_blkfir,
	round(min(f.black_owned_firms)::numeric,1) as min_blkfir,
	round((max(f.black_owned_firms)::numeric - min(f.black_owned_firms)::numeric) / 4,1) as interval_blkfir,
	
	round(max(f.american_indian_alaska_native_owned_firms)::numeric,1) as max_indfir,
	round(min(f.american_indian_alaska_native_owned_firms)::numeric,1) as min_indfir,
	round((max(f.american_indian_alaska_native_owned_firms)::numeric - min(f.american_indian_alaska_native_owned_firms)::numeric) / 4,1) as interval_indfir,
		
	round(max(f.asian_owned_firms)::numeric,1) as max_asifir,
	round(min(f.asian_owned_firms)::numeric,1) as min_asifir,
	round((max(f.asian_owned_firms)::numeric - min(f.asian_owned_firms)::numeric) / 4,1) as interval_asifir,
		
	round(max(f.native_hawaiian_owned_firms)::numeric,1) as max_hawfir,
	round(min(f.native_hawaiian_owned_firms)::numeric,1) as min_hawfir,
	round((max(f.native_hawaiian_owned_firms)::numeric - min(f.native_hawaiian_owned_firms)::numeric) / 4,1) as interval_hawfir,
		
	round(max(f.hispanic_owned_firms)::numeric,1) as max_hisfir,
	round(min(f.hispanic_owned_firms)::numeric,1) as min_hisfir,
	round((max(f.hispanic_owned_firms)::numeric - min(f.hispanic_owned_firms)::numeric) / 4,1) as interval_hisfir
from firmy f
where f.party is not null


--Private nonfarm establishments, 2013 

WITH CTE_Tile AS
(
	SELECT f.state, f.county, f.private_nonfarm_establishments,
	 
		 NTILE(4) OVER( ORDER BY f.private_nonfarm_establishments DESC) AS Tile
	    
	FROM firmy f
)
SELECT Tile, MIN(private_nonfarm_establishments) AS Przedzial_od, MAX(private_nonfarm_establishments) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile


SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_establishments between 0 and 234
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_establishments between 234 and 529
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_establishments between 529 and 1353
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_establishments between 1353 and 253227
order by sum_votes_candidate desc

-- nonfarm employment


WITH CTE_Tile AS
(
	SELECT f.state, f.county, f.private_nonfarm_employment,
	 
		 NTILE(4) OVER( ORDER BY f.private_nonfarm_employment DESC) AS Tile
	    
	FROM firmy f
)
SELECT Tile, MIN(private_nonfarm_employment) AS Przedzial_od, MAX(private_nonfarm_employment) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile


SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_employment between 0 and 2340
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_employment between 2340 and 6340
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_employment between 6340 and 18901
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_employment between 18965 and 3799831
order by sum_votes_candidate desc

--Private nonfarm employment, percent change, 2012-2013


WITH CTE_Tile AS
(
	SELECT f.state, f.county, f.private_nonfarm_employment_change,
	 
		 NTILE(4) OVER( ORDER BY f.private_nonfarm_employment_change DESC) AS Tile
	    
	FROM firmy f
)
SELECT Tile, MIN(private_nonfarm_employment_change) AS Przedzial_od, MAX(private_nonfarm_employment_change) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile


SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_employment_change between -71.5 and -1.80
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_employment_change between -1.80 and 0.70
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_employment_change between 0.70 and 3.00
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.private_nonfarm_employment_change between 3.00 and 110.80
order by sum_votes_candidate desc

--non-employer estabishments


WITH CTE_Tile AS
(
	SELECT f.state, f.county, f.nonemployer_establishments,
	 
		 NTILE(4) OVER( ORDER BY f.nonemployer_establishments DESC) AS Tile
	    
	FROM firmy f
)
SELECT Tile, MIN(nonemployer_establishments) AS Przedzial_od, MAX(nonemployer_establishments) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile


SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.nonemployer_establishments between 0 and 792
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.nonemployer_establishments between 792 and 1608
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.nonemployer_establishments between 1608 and 4076
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.nonemployer_establishments between 4091 and 945941
order by sum_votes_candidate desc

--total number of firms

WITH CTE_Tile AS
(
	SELECT f.state, f.county, f.total_number_of_firms,
	 
		 NTILE(4) OVER( ORDER BY f.total_number_of_firms DESC) AS Tile
	    
	FROM firmy f
)
SELECT Tile, MIN(total_number_of_firms) AS Przedzial_od, MAX(total_number_of_firms) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile


SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.total_number_of_firms between 0 and 980
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.total_number_of_firms between 980 and 2125
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.total_number_of_firms between 2125 and 5287
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.total_number_of_firms between 5287 and 1046940
order by sum_votes_candidate desc

--procentowo black

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.black_owned_firms between 50.1 and 66.7
order by sum_votes_candidate desc

SELECT 
	distinct(f.county),
	f.state,
	f.party,
	sum(f.votes) over (partition by f.fips) as sum_votes_county
from firmy f
where f.black_owned_firms between 50.1 and 66.7 
and f.party like 'Democrats'
order by f.state desc


--procentowo native indian

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.american_indian_alaska_native_owned_firms between 41.4 and 55.0
order by sum_votes_candidate desc


--procentowo asian

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.asian_owned_firms between 42.6 and 56.6
order by sum_votes_candidate desc

--procentowo hawaii 

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.native_hawaiian_owned_firms between 7.8 and 10.5
order by sum_votes_candidate desc

--procentowo hispanic 

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.hispanic_owned_firms between 58.5 and 78.0
order by sum_votes_candidate desc


--Women-owned firms, percent, 2007

WITH CTE_Tile AS
(
	SELECT f.state, f.county, f.women_owned_firms ,
	 
		 NTILE(4) OVER( ORDER BY f.women_owned_firms  DESC) AS Tile
	    
	FROM firmy f
)
SELECT Tile, MIN(women_owned_firms ) AS Przedzial_od, MAX(women_owned_firms ) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.women_owned_firms = 0.0
order by sum_votes_candidate desc

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
where f.women_owned_firms between 27.7 and 56.2
order by sum_votes_candidate desc