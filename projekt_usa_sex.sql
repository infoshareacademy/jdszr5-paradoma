-- g�osowanie w zale�no�ci od p�ci
create table sex as
select 
	cf.fips,
	cf.area_name,
	pr.county,	
	pr.candidate,
	pr.party,
	pr.votes,
	pr.fraction_votes,	
	cf."SEX255214" as women_in_county
from county_facts cf
join primary_results pr on cf.fips = pr.fips 

with table_wic as -- obliczenie przedzia��w
(select 
	max(s.women_in_county) as max_wic,
	min(s.women_in_county),
	(max(s.women_in_county) - min(s.women_in_county)) / 4 as interval_wic
from sex s )

select -- obliczenie granicy przedzia�u z najbardziej liczn� grup�
	(max_wic - interval_wic)
from table_wic

SELECT 
	distinct(s.candidate),
	s.party,
	sum(s.votes) over (partition by s.party) as sum_votes_party,
	sum(s.votes) over (partition by s.candidate) as sum_votes_candidate
from sex s 
where s.women_in_county between 50.1 and 57.0
order by sum_votes_candidate DESC

select -- w kt�rych stanach jest najwi�cej kobiet 
	cf.area_name,
	cf."SEX255214" 
from county_facts cf 
where cf.fips like '%000' and cf."SEX255214" > 51.0
order by cf."SEX255214" desc


--kolejne przedzia�y, co si� dzieje kiedy spada liczba kobiet

SELECT 
	distinct(s.candidate),
	s.party,
	sum(s.votes) over (partition by s.party) as sum_votes_party,
	sum(s.votes) over (partition by s.candidate) as sum_votes_candidate
from sex s 
where s.women_in_county between 43.4 and 50.1
order by sum_votes_candidate DESC

SELECT 
	distinct(s.candidate),
	s.party,
	sum(s.votes) over (partition by s.party) as sum_votes_party,
	sum(s.votes) over (partition by s.candidate) as sum_votes_candidate
from sex s 
where s.women_in_county between 36.7 and 43.4
order by sum_votes_candidate DESC

SELECT 
	distinct(s.candidate),
	s.party,
	sum(s.votes) over (partition by s.party) as sum_votes_party,
	sum(s.votes) over (partition by s.candidate) as sum_votes_candidate
from sex s 
where s.women_in_county between 30.0 and 36.7 
order by sum_votes_candidate DESC

select -- w kt�rych stanach jest najwi�cej m�zczyzn 
	cf.area_name,
	cf."SEX255214" 
from county_facts cf 
where cf.fips like '%000' and cf."SEX255214" < 49.8
order by cf."SEX255214" asc
