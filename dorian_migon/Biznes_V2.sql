select * from county_facts cf 
select * from primary_results pr 


-- Czy glosy sa zalezne od biznes

SELECT 
	distinct(f.candidate),
	f.party,
	sum(f.votes) over (partition by f.party) as sum_votes_party,
	sum(f.votes) over (partition by f.candidate) as sum_votes_candidate
from firmy f 
order by sum_votes_candidate desc

create table biznes as
select
	pr.state, 
	pr.county,	
	pr.candidate,
	pr.party,
	pr.votes,
	pr.fraction_votes,
	cf."MAN450207" as manufacturers_shipments,
	cf."WTN220207" as merchant_wholesaler_sales,
	cf."RTN130207" as retail_sales,
	cf."RTN131207" as retail_sales_per_capita,
	cf."AFN120207" as accommodation_and_food_services_sales
from county_facts cf 
inner join primary_results pr on cf.fips = pr.fips 

select * from biznes


--Manufacturers shipments, 2007 ($1,000) 


WITH CTE_Tile AS
(
	SELECT b.state, b.county, b.manufacturers_shipments,
	 
		 NTILE(4) OVER( ORDER BY b.manufacturers_shipments DESC) AS Tile
	    
	FROM biznes b
)
SELECT Tile, MIN(manufacturers_shipments) AS Przedzial_od, MAX(manufacturers_shipments) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile


SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.manufacturers_shipments = 0
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.manufacturers_shipments between 0 and 114991
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.manufacturers_shipments between 114991 and 927058
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.manufacturers_shipments between 927058 and 169275136
order by sum_votes_candidate desc

-- Merchant wholesaler sales


WITH CTE_Tile AS
(
	SELECT b.state, b.county, b.merchant_wholesaler_sales,
	 
		 NTILE(4) OVER( ORDER BY b.merchant_wholesaler_sales DESC) AS Tile
	    
	FROM biznes b
)
SELECT Tile, MIN(merchant_wholesaler_sales) AS Przedzial_od, MAX(merchant_wholesaler_sales) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile


SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.merchant_wholesaler_sales = 0
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.merchant_wholesaler_sales between 0 and 43433
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.merchant_wholesaler_sales between 43433 and 249685
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.merchant_wholesaler_sales between 249685 and 205478752
order by sum_votes_candidate desc


-- retail sales

WITH CTE_Tile AS
(
	SELECT b.state, b.county, b.retail_sales,
	 
		 NTILE(4) OVER( ORDER BY b.retail_sales DESC) AS Tile
	    
	FROM biznes b
)
SELECT Tile, MIN(retail_sales) AS Przedzial_od, MAX(retail_sales) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile


SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.retail_sales between 0 and 83186
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.retail_sales between 83186 and 242911
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.retail_sales between 242911 and 727813
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.retail_sales between 727813 and 119111840
order by sum_votes_candidate desc


-- retail sales per capita



WITH CTE_Tile AS
(
	SELECT b.state, b.county, b.retail_sales_per_capita,
	 
		 NTILE(4) OVER( ORDER BY b.retail_sales_per_capita DESC) AS Tile
	    
	FROM biznes b
)
SELECT Tile, MIN(retail_sales_per_capita) AS Przedzial_od, MAX(retail_sales_per_capita) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile


SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.retail_sales_per_capita between 0 and 6785
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.retail_sales_per_capita between 6785 and 9583
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.retail_sales_per_capita between 9583 and 12670
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.retail_sales_per_capita between 12670 and 80800
order by sum_votes_candidate desc

-- Accommodation and food services sales, 2007 ($1,000)


WITH CTE_Tile AS
(
	SELECT b.state, b.county, b.accommodation_and_food_services_sales,
	 
		 NTILE(4) OVER( ORDER BY b.accommodation_and_food_services_sales DESC) AS Tile
	    
	FROM biznes b
)
SELECT Tile, MIN(accommodation_and_food_services_sales) AS Przedzial_od, MAX(accommodation_and_food_services_sales) AS Przedzial_do, COUNT(*) as ile
FROM CTE_Tile
GROUP BY Tile
ORDER BY Tile


SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.accommodation_and_food_services_sales between 0 and 6490
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.accommodation_and_food_services_sales between 6490 and 23819
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.accommodation_and_food_services_sales between 23819 and 85079
order by sum_votes_candidate desc

SELECT 
	distinct(b.candidate),
	b.party,
	sum(b.votes) over (partition by b.party) as sum_votes_party,
	sum(b.votes) over (partition by b.candidate) as sum_votes_candidate
from biznes b 
where b.accommodation_and_food_services_sales between 85079 and 24857836
order by sum_votes_candidate desc


