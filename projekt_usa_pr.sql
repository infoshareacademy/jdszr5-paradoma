select * from county_facts cf 

--Kto zdoby� ile g�os�w - sumarycznie
select 
	pr.candidate ,
	sum(pr.votes) as all_votes
from primary_results pr 
group by pr.candidate 
order by all_votes DESC 

with table1 as -- stany wykluczone z analizy z powodu niedopasowanych fips'ow
(select 
	pr.state,
	count (*) as num_counties
from primary_results pr 
where pr.fips like '9%'
group by pr.state)

select *
from table1
where num_counties > 20

select *
from primary_results pr 
where pr.state not in ('Alaska', 'Connecticut', 'Kansas', 'Maine', 'Massachusetts', 'North Dakota', 'Rhode Island', 'Vermont', 'Wyoming')

--definicja tabeli dla kategorii etniczno��

create table ethnicity as
select
	cf.fips,	
	pr.state ,
	pr.state_abbreviation,
	pr.county ,
	cf.area_name,
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
join primary_results pr on cf.fips = pr.fips 
where pr.state not in ('Alaska', 'Connecticut', 'Kansas', 'Maine', 'Massachusetts', 'North Dakota', 'Rhode Island', 'Vermont', 'Wyoming')
order by cf.fips 

--korelacje dla poszczeg�lnych partii

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

-- je�li jest korelacja w ramach partii to mo�na wykona� korelacje dla poszczeg�lnych kandydat�w



--na kt�r� parti� / kandydata g�osowa�y hrabstwa, w kt�rych poszczeg�lne grupy etniczne s� najbardziej liczne

with table_baa as -- obliczenie przedzia��w
(select 
	max(e.black_african_american) as max_baa,
	min(e.black_african_american),
	(max(e.black_african_american) - min(e.black_african_american)) / 4 as interval_baa
from ethnicity e )

select -- obliczenie granicy przedzia�u z najbardziej liczn� grup�
	(max_baa - interval_baa)
from table_baa

SELECT -- rozk�ad g�os�w na partie / kandydat�w
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.black_african_american between 63.8 and 85.1
order by sum_votes_candidate DESC 

select 	-- w kt�rych stanach jest najwi�cej hrabstw, w kt�rych mieszka dana grupa etniczna
	e.state,
	count(*) as num_county
from ethnicity e 
where e.black_african_american between 63.8 and 85.1
group by e.state
order by num_county desc

select -- w kt�rych stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do m�czyzn (znacznie mniej informacji ni� z poprzedniego zapytania)
	cf.fips ,
	cf.area_name ,
	cf."RHI225214" ,
	cf."SEX255214"
from county_facts cf 
where cf.fips like '%000' 
order by cf."RHI225214" desc
limit 10

-- jaki faktycznie wp�yw na wybory w danych stanach mia�a okre�lona grupa etniczna
with table_baa as
(select 
	pr.state ,
	pr.party ,
	pr.candidate ,
	sum(pr.votes) as sum_votes
from primary_results pr 
where pr.state in (select e.state from ethnicity e where e.black_african_american between 63.8 and 85.1)
group by pr.candidate, pr.party, pr.state 
order by pr.state asc, sum_votes desc)

select 
	state,	
	party,
	sum(sum_votes) sum_votes_state
from table_baa
group by state, party
order by state asc, sum_votes_state desc

with table_es_baa as
(select 	-- jakie to s� hrabstwa i jaki w nich jest stosunek kobiet do m�czyzn
	distinct(e.area_name) ,
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






with table_ia as -- obliczenie przedzia��w
(select 
	max(e.indian_alaska) as max_ia,
	min(e.indian_alaska),
	(max(e.indian_alaska) - min(e.indian_alaska)) / 4 as interval_ia
from ethnicity e )

select -- obliczenie granicy przedzia�u z najbardziej liczn� grup�
	(max_ia - interval_ia)
from table_ia

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.indian_alaska between 69.1 and 92.2 
order by sum_votes_candidate DESC 

select 	-- w kt�rych stanach jest najwi�cej hrabstw, w kt�rych mieszka dana grupa etniczna
	e.state,
	count(*)  as num_county
from ethnicity e 
where e.indian_alaska between 69.1 and 92.2
group by e.state 
order by num_county desc

select -- w kt�rych stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do m�czyzn (znacznie mniej informacji ni� z poprzedniego zapytania)
	cf.area_name ,
	cf."RHI325214" ,
	cf."SEX255214" 
from county_facts cf 
where cf.fips like '%000'
order by cf."RHI325214" desc
limit 10

-- jaki faktycznie wp�yw na wybory w danych stanach mia�a okre�lona grupa etniczna
with table_ia as
(select 
	pr.state ,
	pr.party ,
	pr.candidate ,
	sum(pr.votes) as sum_votes
from primary_results pr 
where pr.state in (select e.state from ethnicity e where e.indian_alaska between 69.1 and 92.2)
group by pr.candidate, pr.party, pr.state 
order by pr.state asc, sum_votes desc)

select 
	state,	
	party,
	sum(sum_votes) sum_votes_state
from table_ia
group by state, party
order by state asc, sum_votes_state desc

with table_es_ia as
(select 	-- jakie to s� hrabstwa i jaki w nich jest stosunek kobiet do m�czyzn
	distinct(e.area_name) ,
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







with table_as as -- obliczenie przedzia��w
(select 
	max(e.asian) as max_as,
	min(e.asian),
	(max(e.asian) - min(e.asian)) / 4 as interval_as
from ethnicity e )

select -- obliczenie granicy przedzia�u z najbardziej liczn� grup�
	(max_as - interval_as)
from table_as

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.asian between 31.8 and 42.5
order by sum_votes_candidate DESC 

select 	-- w kt�rych stanach jest najwi�cej hrabstw, w kt�rych mieszka dana grupa etniczna
	e.state,
	count(*) as num_county
from ethnicity e 
where e.asian between 31.8 and 42.5
group by e.state 
order by num_county desc

-- jaki faktycznie wp�yw na wybory w danych stanach mia�a okre�lona grupa etniczna
with table_a as
(select 
	pr.state ,
	pr.party ,
	pr.candidate ,
	sum(pr.votes) as sum_votes
from primary_results pr 
where pr.state in (select e.state from ethnicity e where e.asian between 31.8 and 42.5)
group by pr.candidate, pr.party, pr.state 
order by pr.state asc, sum_votes desc)

select 
	state,	
	party,
	sum(sum_votes) sum_votes_state
from table_a
group by state, party
order by state asc, sum_votes_state desc

select -- w kt�rych stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do m�czyzn (znacznie mniej informacji ni� z poprzedniego zapytania)
	cf.area_name ,
	cf."RHI425214" ,
	cf."SEX255214" 
from county_facts cf 
where cf.fips like '%000'
order by cf."RHI425214" desc
limit 10

with table_es_a as
(select 	-- jakie to s� hrabstwa i jaki w nich jest stosunek kobiet do m�czyzn
	e.area_name ,
	e.state ,
	e.asian ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.asian between 31.8 and 42.5
group by 1,2,3,4 
order by e.asian desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_a









with table_h as -- obliczenie przedzia��w
(select 
	max(e.hawaiian) as max_h,
	min(e.hawaiian),
	(max(e.hawaiian) - min(e.hawaiian)) / 4 as interval_h
from ethnicity e
where e.party is not null)

select -- obliczenie granicy przedzia�u z najbardziej liczn� grup�
	(max_h - interval_h)
from table_h 

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.hawaiian between 9.5 and 12.7
order by sum_votes_candidate DESC 

select 	-- w kt�rych stanach jest najwi�cej hrabstw, w kt�rych mieszka dana grupa etniczna
	e.state,
	count(*) as num_county
from ethnicity e 
where e.hawaiian between 9.5 and 12.7
group by e.state 
order by num_county desc

select -- w kt�rych stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do m�czyzn (znacznie mniej informacji ni� z poprzedniego zapytania)
	cf.area_name ,
	cf."RHI525214" ,
	cf."SEX255214" 
from county_facts cf 
where cf.fips like '%000'
order by cf."RHI525214" desc
limit 10

with table_h as -- jaki faktycznie wp�yw na wybory w danych stanach mia�a okre�lona grupa etniczna
(select 
	pr.state ,
	pr.party ,
	pr.candidate ,
	sum(pr.votes) as sum_votes
from primary_results pr 
where pr.state in (select e.state from ethnicity e where e.hawaiian between 9.5 and 12.7)
group by pr.candidate, pr.party, pr.state 
order by pr.state asc, sum_votes desc)

select 
	state,	
	party,
	sum(sum_votes) sum_votes_state
from table_h
group by state, party
order by state asc, sum_votes_state desc

with table_es_h as
(select 	-- jakie to s� hrabstwa i jaki w nich jest stosunek kobiet do m�czyzn
	e.area_name ,
	e.state ,
	e.hawaiian ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.hawaiian between 9.5 and 12.7
group by 1,2,3,4
order by e.hawaiian desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_h







with table_two as -- obliczenie przedzia��w
(select 
	max(e.two_or_more) as max_two,
	min(e.two_or_more),
	(max(e.two_or_more) - min(e.two_or_more)) / 4 as interval_two
from ethnicity e )

select -- obliczenie granicy przedzia�u z najbardziej liczn� grup�
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
where e.two_or_more between 22.0 and 30.0  
order by sum_votes_candidate desc

select 	-- w kt�rych stanach jest najwi�cej hrabstw, w kt�rych mieszka dana grupa etniczna
	e.state,
	count(*) as num_county
from ethnicity e 
where e.two_or_more between 22.0 and 30.0
group by e.state 
order by num_county desc

select -- w kt�rych stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do m�czyzn (znacznie mniej informacji ni� z poprzedniego zapytania)
	cf.area_name ,
	cf."RHI625214" ,
	cf."SEX255214" 
from county_facts cf 
where cf.fips like '%000'
order by cf."RHI625214" desc
limit 10

with table_tom as -- jaki faktycznie wp�yw na wybory w danych stanach mia�a okre�lona grupa etniczna
(select 
	pr.state ,
	pr.party ,
	pr.candidate ,
	sum(pr.votes) as sum_votes
from primary_results pr 
where pr.state in (select e.state from ethnicity e where e.two_or_more between 22.0 and 30.0)
group by pr.candidate, pr.party, pr.state 
order by pr.state asc, sum_votes desc)

select 
	state,	
	party,
	sum(sum_votes) sum_votes_state
from table_tom
group by state, party
order by state asc, sum_votes_state desc

with table_es_tom as
(select 	-- jakie to s� hrabstwa i jaki w nich jest stosunek kobiet do m�czyzn
	e.area_name ,
	e.state ,
	e.two_or_more ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.two_or_more between 22.0 and 30.0
group by 1,2,3,4
order by e.two_or_more desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_tom








with table_hl as -- obliczenie przedzia��w
(select 
	max(e.hispanic_latino) as max_hl,
	min(e.hispanic_latino),
	(max(e.hispanic_latino) - min(e.hispanic_latino)) / 4 as interval_hl
from ethnicity e )

select -- obliczenie granicy przedzia�u z najbardziej liczn� grup�
	(max_hl - interval_hl)
from table_hl

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.hispanic_latino between 71.9 and 96.0 
order by sum_votes_candidate desc

select 	-- w kt�rych stanach jest najwi�cej hrabstw, w kt�rych mieszka dana grupa etniczna
	e.state,
	count(*) as num_county
from ethnicity e 
where e.hispanic_latino between 71.8 and 96.0
group by e.state 
order by num_county desc

select -- w kt�rych stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do m�czyzn (znacznie mniej informacji ni� z poprzedniego zapytania)
	cf.area_name ,
	cf."RHI725214" ,
	cf."SEX255214" 
from county_facts cf 
where cf.fips like '%000'
order by cf."RHI725214" desc
limit 10

with table_hl as -- jaki faktycznie wp�yw na wybory w danych stanach mia�a okre�lona grupa etniczna
(select 
	pr.state ,
	pr.party ,
	pr.candidate ,
	sum(pr.votes) as sum_votes
from primary_results pr 
where pr.state in (select e.state from ethnicity e where e.hispanic_latino between 71.8 and 96.0)
group by pr.candidate, pr.party, pr.state 
order by pr.state asc, sum_votes desc)

select 
	state,	
	party,
	sum(sum_votes) sum_votes_state
from table_hl
group by state, party
order by state asc, sum_votes_state desc

with table_es_hl as
(select 	-- jakie to s� hrabstwa i jaki w nich jest stosunek kobiet do m�czyzn
	e.area_name ,
	e.state ,
	e.hispanic_latino ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.hispanic_latino between 71.8 and 96.0
group by 1,2,3,4
order by e.hispanic_latino desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_hl







with table_wa as -- obliczenie przedzia��w
(select 
	max(e.white_alone) as max_wa,
	min(e.white_alone),
	(max(e.white_alone) - min(e.white_alone)) / 4 as interval_wa
from ethnicity e )

select -- obliczenie granicy przedzia�u z najbardziej liczn� grup�
	(max_wa - interval_wa)
from table_wa

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from ethnicity e 
where e.white_alone between 74.7 and 99.0
order by sum_votes_candidate DESC 

select 	-- w kt�rych stanach jest najwi�cej hrabstw, w kt�rych mieszka dana grupa etniczna
	e.state,
	count(*) as num_county
from ethnicity e 
where e.white_alone between 73.9 and 99.0
group by e.state 
order by num_county desc

select -- w kt�rych stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do m�czyzn (znacznie mniej informacji ni� z poprzedniego zapytania)
	cf.area_name ,
	cf."RHI825214" ,
	cf."SEX255214" 
from county_facts cf 
where cf.fips like '%000'
order by cf."RHI825214" desc
limit 10

with table_wa as -- jaki faktycznie wp�yw na wybory w danych stanach mia�a okre�lona grupa etniczna
(select 
	pr.state ,
	pr.party ,
	pr.candidate ,
	sum(pr.votes) as sum_votes
from primary_results pr 
where pr.state in (select e.state from ethnicity e where e.white_alone between 73.9 and 99.0)
group by pr.candidate, pr.party, pr.state 
order by pr.state asc, sum_votes desc)

select 
	state,	
	party,
	sum(sum_votes) sum_votes_state
from table_wa
group by state, party
order by state asc, sum_votes_state desc

with table_es_wa as
(select 	-- jakie to s� hrabstwa i jaki w nich jest stosunek kobiet do m�czyzn
	e.area_name ,
	e.state ,
	e.white_alone ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.white_alone between 73.9 and 99.0
group by 1,2,3,4
order by e.white_alone desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_wa








with table_fb as -- obliczenie przedzia��w
(select 
	max(e.foreign_born) as max_fb,
	min(e.foreign_born),
	(max(e.foreign_born) - min(e.foreign_born)) / 4 as interval_fb
from ethnicity e )

select -- obliczenie granicy przedzia�u z najbardziej liczn� grup�
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

select 	-- w kt�rych stanach jest najwi�cej hrabstw, w kt�rych mieszka dana grupa etniczna
	e.state,
	count(*) as num_county
from ethnicity e 
where e.foreign_born between 38.4 and 52.0
group by e.state 
order by num_county desc

select -- w kt�rych stanach dana grupa etniczna jest najbardziej liczna, jaka jest proporcja kobiet do m�czyzn (znacznie mniej informacji ni� z poprzedniego zapytania)
	cf.area_name ,
	cf."POP645213" ,
	cf."SEX255214" 
from county_facts cf 
where cf.fips like '%000'
order by cf."POP645213" desc
limit 10

with table_fb as -- jaki faktycznie wp�yw na wybory w danych stanach mia�a okre�lona grupa etniczna
(select 
	pr.state ,
	pr.party ,
	pr.candidate ,
	sum(pr.votes) as sum_votes
from primary_results pr 
where pr.state in (select e.state from ethnicity e where e.foreign_born between 38.4 and 52.0)
group by pr.candidate, pr.party, pr.state 
order by pr.state asc, sum_votes desc)

select 
	state,	
	party,
	sum(sum_votes) sum_votes_state
from table_fb
group by state, party
order by state asc, sum_votes_state desc

with table_es_fb as
(select 	-- jakie to s� hrabstwa i jaki w nich jest stosunek kobiet do m�czyzn
	e.area_name ,
	e.state ,
	e.foreign_born ,
	s.women_in_county 
from ethnicity e 
join sex s on e.fips = s.fips 
where e.foreign_born between 38.4 and 52.0
group by 1,2,3,4
order by e.foreign_born desc)

select 
	min(women_in_county) as min_women,
	max(women_in_county) as max_women,
	avg(women_in_county) as avg_women,
	mode() within group (order by women_in_county) mode_women
from table_es_fb






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





-- g�osowanie w zale�no�ci od wykszta�cenia

create table education as
select
	pr.county,	
	pr.state ,
	pr.candidate,
	pr.party,
	pr.votes,
	pr.fraction_votes,
	cf."EDU635213" as high_school_higher,
	cf."EDU685213" as bachelor_or_higher
from county_facts cf 
join primary_results pr on cf.fips = pr.fips 

SELECT 
	max(e.high_school_higher) as max_hs,
	min(e.high_school_higher),
	(max(e.high_school_higher) - min(e.high_school_higher)) / 4 as interval_hs,
	max(e.bachelor_or_higher) as max_b,
	min(e.bachelor_or_higher),
	(max(e.bachelor_or_higher) - min(e.bachelor_or_higher)) / 4 as interval_b
from education e 


--g�osowanie w zale�no�ci od liczby os�b z wykszta�ceniem high_school (odpowiednik polskiego liceum) lub wy�szym

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
where e.high_school_higher between 58.5 and 72.0
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.high_school_higher between 72.0 and 85.5
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.high_school_higher between 85.5 and 99.0
order by sum_votes_candidate desc

select -- w kt�rych stanach jest najmniej os�b z wykszta�cenie high school lub wy�szym 
	cf.area_name,
	cf."EDU635213" 
from county_facts cf 
where cf.fips like '%000' and cf."EDU635213" < 85.0
order by cf."EDU635213" asc

select -- w kt�rych stanach jest najwi�cej hrabstwa, w kt�rych jest najmniej os�b z wykszta�ceniem �rednim
	e.state ,
	count(*) as num_county
from education e 
where e.high_school_higher between 45.0 and 58.5
group by e.state
order by num_county desc

select -- w kt�rych stanach jest najwi�cej os�b z wykszta�cenie high school lub wy�szym 
	cf.area_name,
	cf."EDU635213" 
from county_facts cf 
where cf.fips like '%000' and cf."EDU635213" > 90.0
order by cf."EDU635213" desc

select -- w kt�rych stanach jest najwi�cej hrabstwa, w kt�rych jest najwi�cej os�b z wykszta�ceniem �rednim
	e.state ,
	count(*) as num_county
from education e 
where e.high_school_higher between 85.5 and 99.0
group by e.state
order by num_county desc




--g�osowanie w zale�no�ci od liczby os�b z wykszta�ceniem bachelor (studia I stopnia, odpowiednik polskiego licencjatu) lub wy�szym

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.bachelor_or_higher between 3.2 and 21.0 
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.bachelor_or_higher between 21.0 and 38.8 
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.bachelor_or_higher between 38.8 and 56.6 
order by sum_votes_candidate DESC

SELECT 
	distinct(e.candidate),
	e.party,
	sum(e.votes) over (partition by e.party) as sum_votes_party,
	sum(e.votes) over (partition by e.candidate) as sum_votes_candidate
from education e 
where e.bachelor_or_higher between 56.6 and 74.5
order by sum_votes_candidate desc

select -- w kt�rych stanach jest najmniej os�b z wykszta�cenie bachelor
	cf.area_name ,	
	cf."EDU685213" 
from county_facts cf 
where cf.fips like '%000' and cf."EDU685213" < 25.0
order by cf."EDU685213" asc

select -- w kt�rych stanach jest najwi�cej hrabstwa, w kt�rych jest najmniej os�b z wykszta�ceniem wy�szym
	e.state ,
	count(*) as num_county
from education e 
where e.bachelor_or_higher between 3.2 and 21.0
group by e.state
order by num_county desc

select -- w kt�rych stanach jest najwi�cej os�b z wykszta�cenie bachelor lub wy�szym 
	cf.area_name,
	cf."EDU685213" 
from county_facts cf 
where cf.fips like '%000' and cf."EDU685213" > 35.0
order by cf."EDU685213" desc

select -- w kt�rych stanach jest najwi�cej hrabstwa, w kt�rych jest najwi�cej os�b z wykszta�ceniem wy�szym
	e.state ,
	count(*) as num_county
from education e 
where e.high_school_higher between 56.6 and 74.5
group by e.state
order by num_county desc





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

--doch�d na osob�
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

select -- w kt�rych stanach jest najmniejszy doch�d na osob�
	cf.area_name ,	
	cf."INC910213" 
from county_facts cf 
where cf.fips like '%000' and cf."INC910213" < 25000
order by cf."INC910213" asc

select -- w kt�rych stanach jest najwi�kszy doch�d na osob�
	cf.area_name ,	
	cf."INC910213" 
from county_facts cf 
where cf.fips like '%000' and cf."INC910213" > 30000
order by cf."INC910213" desc






--�redni przych�d na domostwo
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

select -- w kt�rych stanach jest najmniejszy doch�d na domostwo
	cf.area_name ,	
	cf."INC110213" 
from county_facts cf 
where cf.fips like '%000' and cf."INC110213" < 45000
order by cf."INC110213" asc

select -- w kt�rych stanach jest najwi�kszy doch�d na domostwo
	cf.area_name ,	
	cf."INC110213" 
from county_facts cf 
where cf.fips like '%000' and cf."INC110213" > 60000
order by cf."INC110213" desc






-- osoby �yj�ce poni�ej poziomu ub�stwa
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

select -- w kt�rych stanach jest najwi�cej os�b �yj�cych poni�ej poziomu ub�stwa
	cf.area_name ,	
	cf."PVY020213" 
from county_facts cf 
where cf.fips like '%000' and cf."PVY020213" > 18.0
order by cf."PVY020213" desc

select -- w kt�rych stanach jest najmniej os�b �yj�cych poni�ej poziomu ub�stwa
	cf.area_name ,	
	cf."PVY020213" 
from county_facts cf 
where cf.fips like '%000' and cf."PVY020213" < 11.5
order by cf."PVY020213" asc
