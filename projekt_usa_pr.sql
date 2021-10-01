select * from county_facts cf 

--Kto zdoby³ ile g³osów - sumarycznie
select 
	pr.candidate ,
	sum(pr.votes) as all_votes
from primary_results pr 
group by pr.candidate 
order by all_votes DESC 

--definicja tabeli dla kategorii etnicznoœæ

create table ethnicity as
select
	pr.county ,
	pr.state ,
	coalesce(cf.fips, pr.fips) as fips,
	cf.area_name,
	pr.state_abbreviation,
	pr.candidate ,
	pr.party ,
	pr.votes ,
	pr.fraction_votes ,
	sum(pr.votes) over (partition by pr.county) as sum_votes_in_county,
	cf."RHI125214" as white,
	cf."RHI225214" as black_african_american,
	cf."RHI325214" as indian_alaska,
	cf."RHI425214" as asian,
	cf."RHI525214" as hawaiian,
	cf."RHI625214" as two_or_more,
	cf."RHI725214" as hispanic_latino,
	cf."RHI825214" as white_alone,
	cf."POP645213" as foreign_born
from county_facts cf 
left join primary_results pr on cf.fips = pr.fips 
order by cf.fips 

--korelacje dla poszczególnych partii

with table1 as
(select 
	distinct(e.county),
	e.state,
	(sum(e.votes) over (partition by e.county)) / e.sum_votes_in_county::numeric as fraction_votes_democrat,
	e.white,
	e.black_african_american,
	e.indian_alaska,
	e.asian,
	e.hawaiian,
	e.two_or_more,
	e.hispanic_latino,
	e.white_alone,
	e.foreign_born 
from ethnicity e 
where e.party like 'Democrat' 
order by e.state)


select
	corr(fraction_votes_democrat, white) as corr_w,
	corr(fraction_votes_democrat, black_african_american) as corr_baa,
	corr(fraction_votes_democrat, indian_alaska) as corr_ia,
	corr(fraction_votes_democrat, asian) as corr_as,
	corr(fraction_votes_democrat, hawaiian)as corr_h,
	corr(fraction_votes_democrat, two_or_more) as corr_tom,
	corr(fraction_votes_democrat, hispanic_latino) as corr_hl,
	corr(fraction_votes_democrat, white_alone) as corr_wa,
	corr(fraction_votes_democrat, foreign_born) as corr_fb
from table1

with table2 as
(select 
	distinct(e.county),
	e.state,
	(sum(e.votes) over (partition by e.county)) / e.sum_votes_in_county::numeric as fraction_votes_republican,
	e.white,
	e.black_african_american,
	e.indian_alaska,
	e.asian,
	e.hawaiian,
	e.two_or_more,
	e.hispanic_latino,
	e.white_alone,
	e.foreign_born 
from ethnicity e 
where e.party like 'Republican' 
order by e.state)


select
	corr(fraction_votes_republican, white) as corr_w,
	corr(fraction_votes_republican, black_african_american) as corr_baa,
	corr(fraction_votes_republican, indian_alaska) as corr_ia,
	corr(fraction_votes_republican, asian) as corr_as,
	corr(fraction_votes_republican, hawaiian)as corr_h,
	corr(fraction_votes_republican, two_or_more) as corr_tom,
	corr(fraction_votes_republican, hispanic_latino) as corr_hl,
	corr(fraction_votes_republican, white_alone) as corr_wa,
	corr(fraction_votes_republican, foreign_born) as corr_fb
from table2

-- jeœli jest korelacja w ramach partii to mo¿na wykonaæ korelacje dla poszczególnych kandydatów

--na któr¹ partiê / kandydata g³osowa³y hrabstwa, w których poszczególne grupy etniczne s¹ najbardziej liczne

with table_baa as -- obliczenie przedzia³ów
(select 
	max(e.black_african_american) as max_baa,
	min(e.black_african_american),
	(max(e.black_african_american) - min(e.black_african_american)) / 4 as interval_baa
from ethnicity e )

select -- obliczenie granicy przedzia³u z najbardziej liczn¹ grup¹
	(max_baa - interval_baa)
from table_baa

SELECT -- rozk³ad g³osów na partie / kandydatów
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.black_african_american between 63.8 and 85.1
order by sum_votes_candidate DESC 

select 	-- w których stanach jest najwiêcej hrabstw, w których mieszka dana grupa etniczna
	e.state,
	count(*) as num_county
from ethnicity e 
where e.black_african_american between 63.8 and 85.1
group by e.state 
order by num_county desc

with table_es_baa as
(select 	-- jakie to s¹ hrabstwa i jaki w nich jest stosunek kobiet do mê¿czyzn
	e.area_name ,
	e.state ,
	e.black_african_american ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.black_african_american between 63.8 and 85.1
order by e.black_african_american desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_baa

select -- w których stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do mê¿czyzn (znacznie mniej informacji ni¿ z poprzedniego zapytania)
	e.area_name ,
	e.black_african_american, 
	s.women_in_county
from ethnicity e
join sex s on e.fips = s.fips
where e.black_african_american is not null and e.fips like '%000'
order by e.black_african_american desc
limit 5




with table_ia as -- obliczenie przedzia³ów
(select 
	max(e.indian_alaska) as max_ia,
	min(e.indian_alaska),
	(max(e.indian_alaska) - min(e.indian_alaska)) / 4 as interval_ia
from ethnicity e )

select -- obliczenie granicy przedzia³u z najbardziej liczn¹ grup¹
	(max_ia - interval_ia)
from table_ia


SELECT 
	e.party , 
	sum(e.votes) as sum_votes
from ethnicity e 
where e.indian_alaska between 69.1 and 92.2 and e.party is not null
group by e.party 
order by sum_votes DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.indian_alaska between 69.1 and 92.2 and e.candidate is not null
order by sum_votes_candidate DESC 

select 	-- w których stanach jest najwiêcej hrabstw, w których mieszka dana grupa etniczna
	e.state,
	count(*) over (partition by e.state)  as num_county,
	e.fips 
from ethnicity e 
where e.indian_alaska between 69.1 and 92.2
order by num_county desc

with table_es_ia as
(select 	-- jakie to s¹ hrabstwa i jaki w nich jest stosunek kobiet do mê¿czyzn
	e.area_name ,
	e.state ,
	e.indian_alaska ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.indian_alaska between 69.1 and 92.2
order by e.indian_alaska desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_ia

select -- w których stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do mê¿czyzn (znacznie mniej informacji ni¿ z poprzedniego zapytania)
	e.area_name,
	e.indian_alaska ,
	s.women_in_county
from ethnicity e
join sex s on e.fips = s.fips 
where e.fips like '%000'
order by e.indian_alaska desc
limit 5





with table_as as -- obliczenie przedzia³ów
(select 
	max(e.asian) as max_as,
	min(e.asian),
	(max(e.asian) - min(e.asian)) / 4 as interval_as
from ethnicity e )

select -- obliczenie granicy przedzia³u z najbardziej liczn¹ grup¹
	(max_as - interval_as)
from table_as

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.asian between 31.8 and 42.5 and e.candidate is not null
order by sum_votes_candidate DESC 

select 	-- w których stanach jest najwiêcej hrabstw, w których mieszka dana grupa etniczna
	coalesce(e.state, e.area_name),
	count(*) over (partition by e.state)  as num_county,
	e.fips 
from ethnicity e 
where e.asian between 31.8 and 42.5
order by num_county desc

with table_es_a as
(select 	-- jakie to s¹ hrabstwa i jaki w nich jest stosunek kobiet do mê¿czyzn
	e.area_name ,
	e.state ,
	e.asian ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.asian between 31.8 and 42.5
order by e.asian desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_a

select -- w których stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do mê¿czyzn (znacznie mniej informacji ni¿ z poprzedniego zapytania)
	e.area_name,
	e.asian ,
	s.women_in_county
from ethnicity e
join sex s on e.fips = s.fips 
where e.fips like '%000'
order by e.asian desc
limit 5








with table_h as -- obliczenie przedzia³ów
(select 
	max(e.hawaiian) as max_h,
	min(e.hawaiian),
	(max(e.hawaiian) - min(e.hawaiian)) / 4 as interval_h
from ethnicity e
where e.party is not null)

select -- obliczenie granicy przedzia³u z najbardziej liczn¹ grup¹
	(max_h - interval_h)
from table_h 

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.hawaiian between 9.5 and 12.7 and e.candidate is not null
order by sum_votes_candidate DESC 

select 	-- w których stanach jest najwiêcej hrabstw, w których mieszka dana grupa etniczna
	coalesce(e.state, e.area_name),
	count(*) over (partition by e.state)  as num_county,
	e.fips 
from ethnicity e 
where e.hawaiian between 9.5 and 12.7
order by num_county desc

with table_es_h as
(select 	-- jakie to s¹ hrabstwa i jaki w nich jest stosunek kobiet do mê¿czyzn
	e.area_name ,
	e.state ,
	e.hawaiian ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.hawaiian between 9.5 and 12.7
order by e.hawaiian desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_h

select -- w których stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do mê¿czyzn (znacznie mniej informacji ni¿ z poprzedniego zapytania)
	e.area_name,
	e.hawaiian ,
	s.women_in_county
from ethnicity e
join sex s on e.fips = s.fips 
where e.fips like '%000'
order by e.hawaiian desc
limit 5






with table_two as -- obliczenie przedzia³ów
(select 
	max(e.two_or_more) as max_two,
	min(e.two_or_more),
	(max(e.two_or_more) - min(e.two_or_more)) / 4 as interval_two
from ethnicity e )

select -- obliczenie granicy przedzia³u z najbardziej liczn¹ grup¹
	(max_two - interval_two)
from table_two

SELECT 
	e.party , 
	sum(e.votes) as sum_votes
from ethnicity e 
where e.two_or_more between 22.0 and 30.0 and e.party is not null 
group by e.party 
order by sum_votes DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.two_or_more between 22.0 and 30.0 and e.candidate is not null  
order by sum_votes_candidate desc

select 	-- w których stanach jest najwiêcej hrabstw, w których mieszka dana grupa etniczna
	coalesce(e.state, e.area_name),
	count(*) over (partition by e.state)  as num_county,
	e.fips 
from ethnicity e 
where e.two_or_more between 22.0 and 30.0
order by num_county desc

with table_es_tom as
(select 	-- jakie to s¹ hrabstwa i jaki w nich jest stosunek kobiet do mê¿czyzn
	e.area_name ,
	e.state ,
	e.two_or_more ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.two_or_more between 22.0 and 30.0
order by e.two_or_more desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_tom

select -- w których stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do mê¿czyzn (znacznie mniej informacji ni¿ z poprzedniego zapytania)
	e.area_name,
	e.two_or_more ,
	s.women_in_county
from ethnicity e
join sex s on e.fips = s.fips 
where e.fips like '%000'
order by e.two_or_more desc
limit 5







with table_hl as -- obliczenie przedzia³ów
(select 
	max(e.hispanic_latino) as max_hl,
	min(e.hispanic_latino),
	(max(e.hispanic_latino) - min(e.hispanic_latino)) / 4 as interval_hl
from ethnicity e )

select -- obliczenie granicy przedzia³u z najbardziej liczn¹ grup¹
	(max_hl - interval_hl)
from table_hl

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.hispanic_latino between 71.8 and 96.0 
order by sum_votes_candidate desc

select 	-- w których stanach jest najwiêcej hrabstw, w których mieszka dana grupa etniczna
	coalesce(e.state, e.area_name),
	count(*) over (partition by e.state)  as num_county,
	e.fips 
from ethnicity e 
where e.hispanic_latino between 71.8 and 96.0
order by num_county desc

with table_es_hl as
(select 	-- jakie to s¹ hrabstwa i jaki w nich jest stosunek kobiet do mê¿czyzn
	e.area_name ,
	e.state ,
	e.hispanic_latino ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.hispanic_latino between 71.8 and 96.0
order by e.hispanic_latino desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_hl

select -- w których stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do mê¿czyzn (znacznie mniej informacji ni¿ z poprzedniego zapytania)
	e.area_name,
	e.hispanic_latino ,
	s.women_in_county
from ethnicity e
join sex s on e.fips = s.fips 
where e.fips like '%000'
order by e.hispanic_latino desc
limit 5






with table_wa as -- obliczenie przedzia³ów
(select 
	max(e.white_alone) as max_wa,
	min(e.white_alone),
	(max(e.white_alone) - min(e.white_alone)) / 4 as interval_wa
from ethnicity e )

select -- obliczenie granicy przedzia³u z najbardziej liczn¹ grup¹
	(max_wa - interval_wa)
from table_wa

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.white_alone between 73.9 and 99.0 and e.candidate is not null 
order by sum_votes_candidate DESC 

select 	-- w których stanach jest najwiêcej hrabstw, w których mieszka dana grupa etniczna
	coalesce(e.state, e.area_name),
	count(*) over (partition by e.state)  as num_county,
	e.fips 
from ethnicity e 
where e.white_alone between 73.9 and 99.0
order by num_county desc

with table_es_wa as
(select 	-- jakie to s¹ hrabstwa i jaki w nich jest stosunek kobiet do mê¿czyzn
	e.area_name ,
	e.state ,
	e.white_alone ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.white_alone between 73.9 and 99.0
order by e.white_alone desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_wa

select -- w których stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do mê¿czyzn (znacznie mniej informacji ni¿ z poprzedniego zapytania)
	e.area_name,
	e.white_alone ,
	s.women_in_county
from ethnicity e
join sex s on e.fips = s.fips 
where e.fips like '%000'
order by e.white_alone desc
limit 5









with table_fb as -- obliczenie przedzia³ów
(select 
	max(e.foreign_born) as max_fb,
	min(e.foreign_born),
	(max(e.foreign_born) - min(e.foreign_born)) / 4 as interval_fb
from ethnicity e 
where e.party is not null)

select -- obliczenie granicy przedzia³u z najbardziej liczn¹ grup¹
	(max_fb - interval_fb)
from table_fb

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.foreign_born between 38.4 and 52.0 
order by sum_votes_candidate DESC 

select 	-- w których stanach jest najwiêcej hrabstw, w których mieszka dana grupa etniczna
	coalesce(e.state, e.area_name),
	count(*) over (partition by e.state)  as num_county,
	e.fips 
from ethnicity e 
where e.foreign_born between 38.4 and 52.0
order by num_county desc

with table_es_fb as
(select 	-- jakie to s¹ hrabstwa i jaki w nich jest stosunek kobiet do mê¿czyzn
	e.area_name ,
	e.state ,
	e.foreign_born ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.foreign_born between 38.4 and 52.0
order by e.foreign_born desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_fb

select -- w których stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do mê¿czyzn (znacznie mniej informacji ni¿ z poprzedniego zapytania)
	e.area_name,
	e.foreign_born ,
	s.women_in_county
from ethnicity e
join sex s on e.fips = s.fips 
where e.fips like '%000'
order by e.foreign_born desc
limit 5





-- g³osowanie w zale¿noœci od p³ci
create table sex as
select 
	coalesce(cf.fips, pr.fips) as fips,
	cf.area_name,
	pr.county,	
	pr.candidate,
	pr.party,
	pr.votes,
	pr.fraction_votes,	
	cf."SEX255214" as women_in_county
from county_facts cf
left join primary_results pr on cf.fips = pr.fips 

with table_wic as -- obliczenie przedzia³ów
(select 
	max(s.women_in_county) as max_wic,
	min(s.women_in_county),
	(max(s.women_in_county) - min(s.women_in_county)) / 4 as interval_wic
from sex s 
where s.party is not null)

select -- obliczenie granicy przedzia³u z najbardziej liczn¹ grup¹
	(max_wic - interval_wic)
from table_wic

SELECT 
	distinct(s.candidate),
	s.party,
	sum(s.votes) over (partition by s.party) as sum_votes_party,
	sum(s.votes) over (partition by s.candidate) as sum_votes_candidate
from sex s 
where s.women_in_county between 50.1 and 57.0 and s.candidate is not null
order by sum_votes_candidate DESC


--kolejne przedzia³y, co siê dzieje kiedy spada liczba kobiet

SELECT 
	distinct(s.candidate),
	s.party,
	sum(s.votes) over (partition by s.party) as sum_votes_party,
	sum(s.votes) over (partition by s.candidate) as sum_votes_candidate
from sex s 
where s.women_in_county between 43.4 and 50.1 and s.candidate is not null
order by sum_votes_candidate DESC

SELECT 
	distinct(s.candidate),
	s.party,
	sum(s.votes) over (partition by s.party) as sum_votes_party,
	sum(s.votes) over (partition by s.candidate) as sum_votes_candidate
from sex s 
where s.women_in_county between 36.7 and 43.4 and s.candidate is not null
order by sum_votes_candidate DESC

SELECT 
	distinct(s.candidate),
	s.party,
	sum(s.votes) over (partition by s.party) as sum_votes_party,
	sum(s.votes) over (partition by s.candidate) as sum_votes_candidate
from sex s 
where s.women_in_county between 30.0 and 36.7 and s.candidate is not null
order by sum_votes_candidate DESC







-- g³osowanie w zale¿noœci od wykszta³cenia

create table education as
select
	pr.county,	
	pr.candidate,
	pr.party,
	pr.votes,
	pr.fraction_votes,
	cf."EDU635213" as high_school_higher,
	cf."EDU685213" as bachelor_or_higher
from county_facts cf 
left join primary_results pr on cf.fips = pr.fips 

SELECT 
	max(e.high_school_higher) as max_hs,
	min(e.high_school_higher),
	(max(e.high_school_higher) - min(e.high_school_higher)) / 4 as interval_hs,
	max(e.bachelor_or_higher) as max_b,
	min(e.bachelor_or_higher),
	(max(e.bachelor_or_higher) - min(e.bachelor_or_higher)) / 4 as interval_b
from education e 
where e.party is not null


--g³osowanie w zale¿noœci od liczby osób z wykszta³ceniem high_school (odpowiednik polskiego liceum) lub wy¿szym

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.high_school_higher between 45.0 and 58.5 
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.high_school_higher between 58.5 and 72.0 and e.candidate is not null
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.high_school_higher between 72.0 and 85.5 and e.candidate is not null
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.high_school_higher between 85.5 and 99.0 and e.candidate is not null 
order by sum_votes_candidate DESC



--g³osowanie w zale¿noœci od liczby osób z wykszta³ceniem bachelor (studia I stopnia, odpowiednik polskiego licencjatu) lub wy¿szym

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.bachelor_or_higher between 3.2 and 21.0 and e.candidate is not null
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.bachelor_or_higher between 21.0 and 38.8 and e.candidate is not null
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.bachelor_or_higher between 38.8 and 56.6 and e.candidate is not null 
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.bachelor_or_higher between 56.6 and 74.5 and e.candidate is not null
--group by e.candidate 
order by sum_votes_candidate DESC