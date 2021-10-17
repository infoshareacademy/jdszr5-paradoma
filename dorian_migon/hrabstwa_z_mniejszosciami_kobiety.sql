--hrabstwa ktore zawieraly duze % mniejszoœci

create table firmy_etno2 as
select
	pr.state, 
	pr.county,	
	pr.candidate,
	pr.party,
	pr.votes,
	pr.fraction_votes,
	pr.fips,
	sum(pr.votes) over (partition by pr.fips) as sum_votes_in_county,
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

--black



SELECT 
	distinct(fe.county),
	fe.state,
	fe.party,
	sum(fe.votes) over (partition by fe.fips) as sum_votes_county
from firmy_etno2 fe
where fe.black_owned_firms between 50.1 and 66.7 
and fe.party like 'Democrat'
order by sum_votes_county desc

--native indian

SELECT 
	distinct(fe.county),
	fe.state,
	fe.party,
	sum(fe.votes) over (partition by fe.fips) as sum_votes_county
from firmy_etno2 fe
where fe.american_indian_alaska_native_owned_firms between 41.4 and 55.0
and fe.party like 'Democrat'
order by sum_votes_county desc

-- asian

SELECT 
	distinct(fe.county),
	fe.state,
	fe.party,
	sum(fe.votes) over (partition by fe.fips) as sum_votes_county
from firmy_etno2 fe
where fe.asian_owned_firms between 42.6 and 56.6
and fe.party like 'Democrat'
order by sum_votes_county desc

-- hawaii 


SELECT 
	distinct(fe.county),
	fe.state,
	fe.party,
	sum(fe.votes) over (partition by fe.fips) as sum_votes_county
from firmy_etno2 fe
where fe.native_hawaiian_owned_firms between 7.8 and 10.5
and fe.party like 'Democrat'
order by sum_votes_county desc

-- hispanic 

SELECT 
	distinct(fe.county),
	fe.state,
	fe.party,
	sum(fe.votes) over (partition by fe.fips) as sum_votes_county
from firmy_etno2 fe
where fe.hispanic_owned_firms between 58.5 and 78.0
and fe.party like 'Democrat'
order by sum_votes_county desc


-- kobiety
SELECT 
	distinct(fe.county),
	fe.state,
	fe.party,
	sum(fe.votes) over (partition by fe.fips) as sum_votes_county
from firmy_etno2 fe
where fe.women_owned_firms = 0.0
and fe.party like 'Republican'
order by sum_votes_county desc
limit 100


SELECT 
	distinct(fe.county),
	fe.state,
	fe.party,
	sum(fe.votes) over (partition by fe.fips) as sum_votes_county
from firmy_etno2 fe
where fe.women_owned_firms between 27.7 and 56.2 
and fe.party like 'Democrat'
order by sum_votes_county desc
limit 100

with korelacja3 as
(select 
	distinct(fe.county),
	fe.state,
	(sum(fe.votes) over (partition by fe.fips)) / fe.sum_votes_in_county::numeric as fraction_votes_republican,
	fe.women_owned_firms
from firmy_etno2 fe 
where 
fe.party like 'Republican' and 
fe.sum_votes_in_county > 0
order by fe.state)
select
	round(corr(fraction_votes_republican, women_owned_firms)::numeric,2) as corr_1

from korelacja3