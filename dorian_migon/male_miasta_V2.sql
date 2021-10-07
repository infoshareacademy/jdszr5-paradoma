--tabela z deskryptorami z Firma i biznes ktore charakteryzowala sie przewaga Republikanow <Q3
create table male_miasta4 as
select
	pr.fips,
	pr.state, 
	pr.county,	
	pr.candidate,
	pr.party,
	pr.votes,
	pr.fraction_votes,
	sum(pr.votes) over (partition by pr.fips) as sum_votes_in_county,
	cf."BZA010213" as private_nonfarm_establishments,
	cf."NES010213" as nonemployer_establishments,
	cf."BZA110213" as private_nonfarm_employment,
	cf."SBO001207" as total_number_of_firms,
	cf."MAN450207" as manufacturers_shipments,
	cf."WTN220207" as merchant_wholesaler_sales,
	cf."RTN130207" as retail_sales,
	cf."AFN120207" as accommodation_and_food_services_sales
from county_facts cf 
inner join primary_results pr on cf.fips = pr.fips 

--glosy kiedy wszystkie deskryptory z Firma i biznes ktore charakteryzowala sie przewaga Republikanow <Q3 zostana zaaplikowane
SELECT 
	distinct(m.candidate),
	m.party,
	sum(m.votes) over (partition by m.party) as sum_votes_party,
	sum(m.votes) over (partition by m.candidate) as sum_votes_candidate
from male_miasta4 m 
where m.private_nonfarm_establishments between 0 and 1353 and
private_nonfarm_employment between 0 and 18901 and
nonemployer_establishments between 0 and 4076 and
total_number_of_firms between 0 and 785205 and
manufacturers_shipments between 0 and 927058 and 
merchant_wholesaler_sales between 0 and 249685 and 
retail_sales between 0 and 727813 and
accommodation_and_food_services_sales between 0 and 85079
order by sum_votes_candidate desc

--lista counties z najwieksza liczba glosow na republikanow z deskryptorami
SELECT 
	distinct(m.county),
	m.state,
	m.party,
	sum(m.votes) over (partition by m.fips) as sum_votes_county
from male_miasta4 m 
where m.private_nonfarm_establishments between 0 and 1353 and
private_nonfarm_employment between 0 and 18901 and
nonemployer_establishments between 0 and 4076 and
total_number_of_firms between 0 and 785205 and
manufacturers_shipments between 0 and 927058 and 
merchant_wholesaler_sales between 0 and 249685 and 
retail_sales between 0 and 727813 and
accommodation_and_food_services_sales between 0 and 85079
and m.party like 'Republican' 
order by sum_votes_county desc
limit 100

select * from male_miasta3 

----korelacja pomiedzy kombinacja a frakcja glos?w na republikan?w
with korelacja as
(select 
	distinct(m.county),
	m.state,
	(sum(m.votes) over (partition by m.fips)) / m.sum_votes_in_county::numeric as fraction_votes_republican,
	m.private_nonfarm_establishments,
	m.private_nonfarm_employment,
	m.nonemployer_establishments,
	m.total_number_of_firms,
	m.manufacturers_shipments,
	m.merchant_wholesaler_sales,
	m.retail_sales,
	m.accommodation_and_food_services_sales
from male_miasta4 m 
where 
m.party like 'Republican' and 
m.sum_votes_in_county > 0
order by m.state)
select
	round(corr(fraction_votes_republican, private_nonfarm_establishments)::numeric,2) as corr_1,
	round(corr(fraction_votes_republican, private_nonfarm_employment)::numeric,2) as corr_2,
	round(corr(fraction_votes_republican, nonemployer_establishments)::numeric,2) as corr_3,
	round(corr(fraction_votes_republican, total_number_of_firms)::numeric,2) as corr_4,
	round(corr(fraction_votes_republican, manufacturers_shipments)::numeric,2) as corr_5,
	round(corr(fraction_votes_republican, merchant_wholesaler_sales)::numeric,2) as corr_6,
	round(corr(fraction_votes_republican, retail_sales)::numeric,2) as corr_7,
	round(corr(fraction_votes_republican, accommodation_and_food_services_sales)::numeric,2) as corr_8

from korelacja

