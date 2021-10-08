select
	distinct candidate,
	party
from
	primary_results pr

create table sum_votes as 
select 
state_abbreviation, state, fips, county, sum(votes)::numeric as votes_sum 
from primary_results pr 
where  state_abbreviation <> '' 
group by state_abbreviation, fips, county, state 
order by state, county

-- suma wszystkich glosow w USA na poszczegolnych kandydatow
select candidate, sum(votes) as all_vot from primary_results pr group by candidate order by all_vot desc

-- tabele dodajce poszczegolnych kandydatow z ich wynikami w ujeciu liczby glosow oraz procentowej frakcji w danym hrabstwie
create table rep1 as
select 
sv.fips, pr.state, pr.state_abbreviation, pr.county, pr.party, pr.candidate, (pr.votes / sv.votes_sum)::numeric as percent_rep1, pr.votes as votes_rep1 
from primary_results pr  
join sum_votes sv on pr.fips = sv.fips 
where candidate = 'Donald Trump'

create table rep2 as
select 
sv.fips, pr.state, pr.state_abbreviation, pr.county, pr.party, pr.candidate, (pr.votes / sv.votes_sum)::numeric as percent_rep2, pr.votes as votes_rep2 
from primary_results pr  
join sum_votes sv on pr.fips = sv.fips 
where candidate = 'Ted Cruz'

create table rep3 as
select 
sv.fips, pr.state, pr.state_abbreviation, pr.county, pr.party, pr.candidate, (pr.votes / sv.votes_sum)::numeric as percent_rep3, pr.votes as votes_rep3 
from primary_results pr  
join sum_votes sv on pr.fips = sv.fips 
where candidate = 'Ben Carson'

create table rep4 as
select 
sv.fips, pr.state, pr.state_abbreviation, pr.county, pr.party, pr.candidate, (pr.votes / sv.votes_sum)::numeric as percent_rep4, pr.votes as votes_rep4 
from primary_results pr  
join sum_votes sv on pr.fips = sv.fips 
where candidate = 'Marco Rubio'

create table rep5 as
select 
sv.fips, pr.state, pr.state_abbreviation, pr.county, pr.party, pr.candidate, (pr.votes / sv.votes_sum)::numeric as percent_rep5, pr.votes as votes_rep5 
from primary_results pr  
join sum_votes sv on pr.fips = sv.fips 
where candidate = 'John Kasich'

create table rep6 as
select 
sv.fips, pr.state, pr.state_abbreviation, pr.county, pr.party, pr.candidate, (pr.votes / sv.votes_sum)::numeric as percent_rep6, pr.votes as votes_rep6 
from primary_results pr  
join sum_votes sv on pr.fips = sv.fips 
where candidate = 'Jeb Bush'

create table dem1 as
select 
sv.fips, pr.state, pr.state_abbreviation, pr.county, pr.party, pr.candidate, (pr.votes / sv.votes_sum)::numeric as percent_dem1, pr.votes as votes_dem1 
from primary_results pr  
join sum_votes sv on pr.fips = sv.fips 
where candidate = 'Hillary Clinton'

create table dem2 as
select 
sv.fips, pr.state, pr.state_abbreviation, pr.county, pr.party, pr.candidate, (pr.votes / sv.votes_sum)::numeric as percent_dem2, pr.votes as votes_dem2 
from primary_results pr  
join sum_votes sv on pr.fips = sv.fips 
where candidate = 'Bernie Sanders'

--najludniejsze hrabstwa
select cf.fips, cf.state_abbreviation, cf.area_name, "PST045214", 

round(percent_rep1*100,2) as Trump, 
round(percent_rep2*100,2) as Cruz, 
round(percent_dem1*100,2) as Clinton, 
round(percent_dem2*100,2) as Sanders, 
round(percent_rep3*100,2) as Carson, 
round(percent_rep4*100,2) as Rubio, 
round(percent_rep5*100,2) as Kasich 

from county_facts cf 
left join rep1 r on cf.fips = r.fips 
left join rep2 r2 on cf.fips = r2.fips
left join dem1 d on cf.fips = d.fips
left join dem2 d2 on cf.fips = d2.fips
left join rep3 r3 on cf.fips = r3.fips 
left join rep4 r4 on cf.fips = r4.fips
left join rep5 r5 on cf.fips = r5.fips 
where cf.state_abbreviation <> '' 
group by cf.fips, cf.state_abbreviation, cf.area_name, "PST045214", percent_rep1, percent_rep2, percent_dem1, percent_dem2, percent_rep3, percent_rep4, percent_rep5  
order by "PST045214" desc limit 20

--wyliczenie 1 i 3 kwartyli dla deskryptora "PST045214" 
select
percentile_disc(0.25) within group (order by "PST045214") as kwartyl1, 
percentile_disc(0.75) within group (order by "PST045214") as kwartyl3 
from county_facts cf 

--ludnosc 3 kwartyl (with i select dla kandydatow, zrobiona tabela test i select dla partii)
create table test as

with all_votes as (
		select cf."PST045214", candidate, party, sum(votes) as vs from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."PST045214" >= 72583 group by pr.candidate, party, cf."PST045214" order by sum(votes) desc
		)
select candidate, party, sum(vs) as vs
from all_votes 
group by candidate, party 
order by sum(vs) desc
				
select 
test.party, sum(vs)
from test
group by party


--ludnosc 1 kwartyl wedlug partii
with all_votes as (
		select cf."PST045214", candidate, party, sum(votes) as vs from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."PST045214" <= 11125 group by pr.candidate, party, cf."PST045214" order by sum(votes) desc
		)
select party, sum(vs) 
from all_votes 
group by party
order by sum(vs) desc
		
--ludnosc 1 kwartyl wedlug kandydatow
with all_votes as (
		select cf."PST045214", candidate, party, sum(votes) as vs from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."PST045214" <= 11125 group by pr.candidate, party, cf."PST045214" order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_votes 
group by candidate, party
order by sum(vs) desc

--ludnosc hrabstwa powzyej 1mln - wyniki wedlug kandydatow
with all_votes as (
		select cf."PST045214", candidate, party, sum(votes) as vs from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."PST045214" > 1000000 group by pr.candidate, cf."PST045214", party 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_votes 
group by candidate, party 
order by sum(vs) desc

--ludnosc hrabstwa powzyej 1mln - wyniki wedlug partii
with all_votes as (
		select cf."PST045214", candidate, party, sum(votes) as vs from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."PST045214" > 1000000 group by pr.candidate, cf."PST045214", party 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_votes 
group by party
order by sum(vs) desc

--najmniej ludne hrabstwa
select cf.fips, cf.state_abbreviation, cf.area_name, "PST045214", 
round(percent_rep1*100,2) as Trump, 
round(percent_rep2*100,2) as Cruz, 
round(percent_dem1*100,2) as Clinton, 
round(percent_dem2*100,2) as Sanders, 
round(percent_rep3*100,2) as Carson, 
round(percent_rep4*100,2) as Rubio, 
round(percent_rep5*100,2) as Kasich from county_facts cf 
left join rep1 r on cf.fips = r.fips 
left join rep2 r2 on cf.fips = r2.fips
left join dem1 d on cf.fips = d.fips
left join dem2 d2 on cf.fips = d2.fips
left join rep3 r3 on cf.fips = r3.fips 
left join rep4 r4 on cf.fips = r4.fips
left join rep5 r5 on cf.fips = r5.fips 
where cf.state_abbreviation <> '' 
group by cf.fips, cf.state_abbreviation, cf.area_name, "PST045214", percent_rep1, percent_rep2, percent_dem1, percent_dem2, percent_rep3, percent_rep4, percent_rep5  
order by "PST045214" asc limit 20

--najbardziej ludne stany USA
select cf.state_abbreviation, sum("PST045214") from county_facts cf 
where cf.state_abbreviation <> '' group by cf.state_abbreviation order by sum("PST045214") desc limit 6

--jak glosowala kalifornia
with all_votes_CA as (
	select state_abbreviation, sum(votes)::numeric as suma 
	from primary_results pr 
	where state_abbreviation = 'CA' 
	group by state_abbreviation				
	)
select 
state_abbreviation, candidate, sum(votes), round(sum(votes)/(select suma from all_votes_CA),4)*100.0 as procent 
from primary_results pr 
where state_abbreviation = 'CA' 
group by state_abbreviation, candidate 
order by sum(votes) desc

--jak glosowali w LA (najwieksze hrabstwo pod wzgledem ludnosci)
with all_votes_CA as (
	select fips, sum(votes)::numeric as suma 
	from primary_results pr 
	where fips = '6037' 
	group by fips				
)
select fips, candidate, sum(votes), round(sum(votes)/(select suma from all_votes_CA),4)*100.0 as procent 
from primary_results pr 
where fips = '6037' 
group by fips , candidate 
order by sum(votes) desc



--najmnniej ludne stany USA
select 
cf.state_abbreviation, sum("PST045214") 
from county_facts cf 
where cf.state_abbreviation <> '' 
group by cf.state_abbreviation 
order by sum("PST045214") asc limit 10

--jak glosowalo WY
select state_abbreviation, candidate, sum(votes) 
from primary_results pr 
where state_abbreviation = 'WY' 
group by state_abbreviation, candidate 
order by sum(votes) desc

--kwartyle dynamika spadku/wzrostu ludnosci w latach 2010-2014
select
percentile_disc(0.25) within group (order by "PST120214") as kwartyl1, 
percentile_disc(0.75) within group (order by "PST120214") as kwartyl3 
from county_facts cf 

--dynamika wzrostu powyzej 8
with all_votes_dynamic as (
		select cf."PST120214", candidate, sum(votes) as vs from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."PST120214" > 8.0 group by pr.candidate, cf."PST120214" order by sum(votes) desc
		)
select candidate, sum(vs) from all_votes_dynamic group by candidate order by sum(vs) desc

--dynamika wzrostu 3 kwartyl wedlug kandydatow
with all_votes_dynamic as (
		select cf."PST120214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."PST120214" >= 2.3 
		group by pr.candidate, party, cf."PST120214" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_votes_dynamic 
group by candidate, party 
order by sum(vs) desc

--dynamika wzrostu 3 kwartyl wedlug partii
with all_votes_dynamic as (
		select cf."PST120214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."PST120214" >= 2.3 
		group by pr.candidate, party, cf."PST120214" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_votes_dynamic 
group by party 
order by sum(vs) desc

--dynamika 1 kwartyl wedlug kandydatow
with all_votes_dynamic as (
		select cf."PST120214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."PST120214" <= -1.9 
		group by pr.candidate, party, cf."PST120214" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_votes_dynamic 
group by candidate, party 
order by sum(vs) desc

--dynamika 1 kwartyl wedlug partii
with all_votes_dynamic as (
		select cf."PST120214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."PST120214" <= -1.9 
		group by pr.candidate, party, cf."PST120214" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_votes_dynamic 
group by party 
order by sum(vs) desc

--dynamika wzrostu populacji wedlug hrabstw
select 
fips, state_abbreviation, area_name, round("PST120214"::numeric ,2) 
from county_facts cf 
where cf.state_abbreviation <> '' 
group by fips, state_abbreviation, area_name, "PST120214" 
order by "PST120214" desc limit 20

--dynamika wzrostu populacji - srednia dla stanow z najwiekszym odsetkiem
select 
cf.state_abbreviation, round(avg("PST120214")::numeric ,2) 
from county_facts cf 
where cf.state_abbreviation <> '' 
group by cf.state_abbreviation 
order by avg("PST120214") desc limit 10

--glosowanie w Detroit
with all_votes_DE as (
	select state_abbreviation, sum(votes)::numeric as suma 
	from primary_results pr 
	where state_abbreviation = 'DE' 
	group by state_abbreviation				
)
select state_abbreviation, candidate, sum(votes), round(sum(votes)/(select suma from all_votes_DE),4)*100.0 as procent 
from primary_results pr 
where state_abbreviation = 'DE' 
group by state_abbreviation, candidate 
order by sum(votes) desc

--dynamika wzrostu populacji - srednia dla stanow z najgorszym odsetkiem
select cf.state_abbreviation, round(avg("PST120214")::numeric ,2) 
from county_facts cf 
where cf.state_abbreviation <> '' 
group by cf.state_abbreviation 
order by avg("PST120214") asc limit 10

--glosowanie w IL
with all_votes_IL as (
	select state_abbreviation, sum(votes)::numeric as suma 
	from primary_results pr 
	where state_abbreviation = 'IL' 
	group by state_abbreviation				
)
select state_abbreviation, candidate, sum(votes), round(sum(votes)/(select suma from all_votes_IL),4)*100.0 as procent 
from primary_results pr 
where state_abbreviation = 'IL' 
group by state_abbreviation, candidate 
order by sum(votes) desc

--dynamika wzrostu popluacji wedlug z hrabstw z najwiekszym odsetkiem - wyniki z kandydatami
select cf.fips, cf.state_abbreviation, cf.area_name, "PST120214", 
round(percent_rep1*100,2) as Trump, 
round(percent_rep2*100,2) as Cruz, 
round(percent_dem1*100,2) as Clinton, 
round(percent_dem2*100,2) as Sanders, 
round(percent_rep3*100,2) as Carson, 
round(percent_rep4*100,2) as Rubio, 
round(percent_rep5*100,2) as Kasich from county_facts cf 
left join rep1 r on cf.fips = r.fips 
left join rep2 r2 on cf.fips = r2.fips
left join dem1 d on cf.fips = d.fips
left join dem2 d2 on cf.fips = d2.fips
left join rep3 r3 on cf.fips = r3.fips 
left join rep4 r4 on cf.fips = r4.fips
left join rep5 r5 on cf.fips = r5.fips 
where cf.state_abbreviation <> '' 
group by cf.fips, cf.state_abbreviation, cf.area_name, "PST120214", percent_rep1, percent_rep2, percent_dem1, percent_dem2, percent_rep3, percent_rep4, percent_rep5  
order by "PST120214" desc limit 20

--odsetek obywateli ponizej 5 roku zycia wedlug hrabstw
select fips, state_abbreviation, area_name, round("AGE135214"::numeric ,2) 
from county_facts cf 
where cf.state_abbreviation <> '' 
group by fips, state_abbreviation, area_name, "AGE135214" 
order by "AGE135214" desc limit 20

--odsetek obywateli ponizej 5 roku zycia srednia dla stanow z najwieksza wartoscia
select cf.state_abbreviation, round(avg("AGE135214")::numeric ,2) from county_facts cf 
where cf.state_abbreviation <> '' group by cf.state_abbreviation order by avg("AGE135214") desc limit 10

--glosowanie w UT
with all_votes_UT as (
	select state_abbreviation, sum(votes)::numeric as suma 
	from primary_results pr 
	where state_abbreviation = 'UT' 
	group by state_abbreviation				
)
select state_abbreviation, candidate, sum(votes), round(sum(votes)/(select suma from all_votes_UT),4)*100.0 as procent 
from primary_results pr 
where state_abbreviation = 'UT' 
group by state_abbreviation, candidate 
order by sum(votes) desc

--glosowanie w AL
with all_votes_AL as (
	select state_abbreviation, sum(votes)::numeric as suma 
	from primary_results pr 
	where state_abbreviation = 'AL' 
	group by state_abbreviation				
)
select state_abbreviation, candidate, sum(votes), round(sum(votes)/(select suma from all_votes_AL),4)*100.0 as procent 
from primary_results pr 
where state_abbreviation = 'AL' 
group by state_abbreviation, candidate 
order by sum(votes) desc

--kwartyle dla deskryptora odsetka obywateli ponizej 5 roku zycia
select
percentile_disc(0.25) within group (order by "AGE135214") as kwartyl1, 
percentile_disc(0.75) within group (order by "AGE135214") as kwartyl3 
from county_facts cf 

--odsetek obywateli ponizej 5 roku zycia - glosowanie dla 3 kwartylu wedlug kandydatow
with all_votes_10 as (
		select cf."AGE135214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE135214" >= 6.5 
		group by pr.candidate, party, cf."AGE135214" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_votes_10 
group by candidate, party 
order by sum(vs) desc

--odsetek obywateli ponizej 5 roku zycia - glosowanie dla 3 kwartylu wedlug partii
with all_votes_10 as (
		select cf."AGE135214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE135214" >= 6.5 
		group by pr.candidate, party, cf."AGE135214" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_votes_10 
group by party 
order by sum(vs) desc

--odsetek obywateli ponizej 5 roku zycia - glosowanie dla 1 kwartylu wedlug kandydatow
with all_votes_10 as (
		select cf."AGE135214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE135214" <= 5.2 
		group by pr.candidate, party, cf."AGE135214" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_votes_10 
group by candidate, party 
order by sum(vs) desc

--odsetek obywateli ponizej 5 roku zycia - glosowanie dla 1 kwartylu wedlug partii
with all_votes_10 as (
		select cf."AGE135214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE135214" <= 5.2 
		group by pr.candidate, party, cf."AGE135214" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_votes_10 
group by party 
order by sum(vs) desc

--percentile U18
select
percentile_disc(0.25) within group (order by "AGE295214") as kwartyl1, 
percentile_disc(0.75) within group (order by "AGE295214") as kwartyl3 
from county_facts cf 

--odsetek obywateli ponizej 18 roku zycia - glosowanie dla 3 kwartylu wedlug kandydatow
with all_votes_u18 as (
		select cf."AGE295214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE295214" >= 24.2 
		group by pr.candidate, party, cf."AGE295214" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_votes_u18 
group by candidate, party  
order by sum(vs) desc

--odsetek obywateli ponizej 18 roku zycia - glosowanie dla 3 kwartylu wedlug partii
with all_votes_u18 as (
		select cf."AGE295214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE295214" > 24.2 
		group by pr.candidate, party, cf."AGE295214" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_votes_u18 
group by party  
order by sum(vs) desc

--odsetek obywateli ponizej 18 roku zycia - glosowanie dla 1 kwartylu wedlug kandydatow
with all_votes_u18 as (
		select cf."AGE295214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE295214" <= 20.5 
		group by pr.candidate, party, cf."AGE295214" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_votes_u18 
group by candidate, party 
order by sum(vs) desc

--odsetek obywateli ponizej 18 roku zycia - glosowanie dla 1 kwartylu wedlug partii
with all_votes_u18 as (
		select cf."AGE295214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE295214" <= 20.5 
		group by pr.candidate, party, cf."AGE295214" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_votes_u18 
group by party 
order by sum(vs) desc

--percentile over65
select
percentile_disc(0.25) within group (order by "AGE775214") as kwartyl1, 
percentile_disc(0.75) within group (order by "AGE775214") as kwartyl3 
from county_facts cf 

--odsetek obywateli powyzej 65 roku zycia - glosowanie dla 3 kwartylu wg kandydatow
with all_votes_over65 as (
		select cf."AGE775214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE775214" >= 19.8 
		group by pr.candidate, party, cf."AGE775214" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_votes_over65 
group by candidate, party 
order by sum(vs) desc

--odsetek obywateli powyzej 65 roku zycia - glosowanie dla 3 kwartylu wg partii
with all_votes_over65 as (
		select cf."AGE775214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE775214" >= 19.8 
		group by pr.candidate, party, cf."AGE775214" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_votes_over65 
group by party 
order by sum(vs) desc

--odsetek obywateli powyzej 65 roku zycia - glosowanie dla 1 kwartylu wg kandydata
with all_votes_over65 as (
		select cf."AGE775214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE775214" <= 14.7 
		group by pr.candidate, party, cf."AGE775214" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_votes_over65 
group by candidate, party 
order by sum(vs) desc

--odsetek obywateli powyzej 65 roku zycia - glosowanie dla 1 kwartylu wg partii
with all_votes_over65 as (
		select cf."AGE775214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."AGE775214" <= 14.7 
		group by pr.candidate, party, cf."AGE775214" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_votes_over65 
group by party 
order by sum(vs) desc

--percentile veterans
select
percentile_disc(0.25) within group (order by "VET605213") as kwartyl1, 
percentile_disc(0.75) within group (order by "VET605213") as kwartyl3 
from county_facts cf 

--weterani 3. kwartyl wg kandydat
with all_veterans as (
		select cf."VET605213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."VET605213" >= 5922 
		group by pr.candidate, party, cf."VET605213" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_veterans 
group by candidate, party 
order by sum(vs) desc

--weterani 3. kwartyl wg partia
with all_veterans as (
		select cf."VET605213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."VET605213" >= 5922 
		group by pr.candidate, party, cf."VET605213" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_veterans 
group by party 
order by sum(vs) desc

--weterani 1. kwartyl wg kandydat
with all_veterans as (
		select cf."VET605213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."VET605213" <= 903 
		group by pr.candidate, party, cf."VET605213" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_veterans 
group by candidate, party 
order by sum(vs) desc

--weterani 1. kwartyl wg partia
with all_veterans as (
		select cf."VET605213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."VET605213" <= 903 
		group by pr.candidate, party, cf."VET605213" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_veterans 
group by party 
order by sum(vs) desc

--percentile gestosc zaludnienia
select
percentile_disc(0.25) within group (order by "POP060210") as kwartyl1, 
percentile_disc(0.75) within group (order by "POP060210") as kwartyl3 
from county_facts cf 

--gestosc zaludnienia 3. kwartyl wg kandydat
with all_pd as (
		select cf."POP060210", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."POP060210" >= 115.9 
		group by pr.candidate, party, cf."POP060210" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_pd 
group by candidate, party 
order by sum(vs) desc

--gestosc zaludnienia 3. kwartyl wg partia
with all_pd as (
		select cf."POP060210", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."POP060210" >= 115.9 
		group by pr.candidate, party, cf."POP060210" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_pd  
group by party 
order by sum(vs) desc

--gestosc zaludnienia 1. kwartyl wg kandydat
with all_pd as (
		select cf."POP060210", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."POP060210" <= 17 
		group by pr.candidate, party, cf."POP060210" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_pd 
group by candidate, party 
order by sum(vs) desc

--gestosc zaludnienia 1. kwartyl wg partia
with all_pd as (
		select cf."POP060210", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."POP060210" <= 17 
		group by pr.candidate, party, cf."POP060210" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_pd 
group by party 
order by sum(vs) desc

--percentile odsetek osob mieszkajacych 1 roku lub dluzej w tym samym domu
select
percentile_disc(0.25) within group (order by "POP715213") as kwartyl1, 
percentile_disc(0.75) within group (order by "POP715213") as kwartyl3 
from county_facts cf 

--odsetek osob mieszkajacych 1 roku lub dluzej w tym samym domu - 3 kwartyl wg kandydat
with all_thesamehouse as (
		select cf."POP715213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."POP715213" >= 89.3
		group by pr.candidate, party, cf."POP715213" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_thesamehouse 
group by candidate, party 
order by sum(vs) desc

--odsetek osob mieszkajacych 1 roku lub dluzej w tym samym domu - 3 kwartyl wg partia
with all_thesamehouse as (
		select cf."POP715213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."POP715213" >= 89.3
		group by pr.candidate, party, cf."POP715213" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_thesamehouse 
group by party 
order by sum(vs) desc

--odsetek osob mieszkajacych 1 roku lub dluzej w tym samym domu - 1 kwartyl wg kandydat
with all_thesamehouse as (
		select cf."POP715213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."POP715213" <= 84
		group by pr.candidate, party, cf."POP715213" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_thesamehouse 
group by candidate, party 
order by sum(vs) desc

--odsetek osob mieszkajacych 1 roku lub dluzej w tym samym domu - 1 kwartyl wg partia
with all_thesamehouse as (
		select cf."POP715213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."POP715213" <= 84
		group by pr.candidate, party, cf."POP715213" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_thesamehouse 
group by party 
order by sum(vs) desc

--percentile powierzchnia w milach kw.
select
percentile_disc(0.25) within group (order by "LND110210") as kwartyl1, 
percentile_disc(0.75) within group (order by "LND110210") as kwartyl3 
from county_facts cf 

--powierzchnia hrabstwa w milach kw. - 3 kwartyl wg kandydat
with all_lnd as (
		select cf."LND110210", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."LND110210" >= 944.74
		group by pr.candidate, party, cf."LND110210" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_lnd 
group by candidate, party 
order by sum(vs) desc

--powierzchnia hrabstwa w milach kw. - 3 kwartyl wg partia
with all_lnd as (
		select cf."LND110210", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."LND110210" >= 944.74
		group by pr.candidate, party, cf."LND110210" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_lnd  
group by party 
order by sum(vs) desc

--powierzchnia hrabstwa w milach kw. - 1 kwartyl wg kandydat
with all_lnd as (
		select cf."LND110210", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."LND110210" <= 432.41
		group by pr.candidate, party, cf."LND110210" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_lnd 
group by candidate, party 
order by sum(vs) desc

--powierzchnia hrabstwa w milach kw. - 1 kwartyl wg partia
with all_lnd as (
		select cf."LND110210", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."LND110210" <= 432.41
		group by pr.candidate, party, cf."LND110210" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_lnd  
group by party 
order by sum(vs) desc

--percentile pozwolenia na budowe
select
percentile_disc(0.25) within group (order by "BPS030214") as kwartyl1, 
percentile_disc(0.75) within group (order by "BPS030214") as kwartyl3 
from county_facts cf 

--powierzchnia hrabstwa w milach kw. - 3 kwartyl wg kandydat
with all_bps as (
		select cf."BPS030214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."BPS030214" >= 166
		group by pr.candidate, party, cf."BPS030214" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_bps  
group by candidate, party 
order by sum(vs) desc

--powierzchnia hrabstwa w milach kw. - 3 kwartyl wg kandydat
with all_bps as (
		select cf."BPS030214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."BPS030214" >= 166
		group by pr.candidate, party, cf."BPS030214" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_bps  
group by party 
order by sum(vs) desc

--powierzchnia hrabstwa w milach kw. - 1 kwartyl wg kandydat
with all_bps as (
		select cf."BPS030214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."BPS030214" <= 6
		group by pr.candidate, party, cf."BPS030214" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_bps  
group by candidate, party 
order by sum(vs) desc

--powierzchnia hrabstwa w milach kw. - 1 kwartyl wg partia
with all_bps as (
		select cf."BPS030214", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."BPS030214" <= 6
		group by pr.candidate, party, cf."BPS030214" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_bps  
group by party 
order by sum(vs) desc

--percentile dojazd do pracy
select
percentile_disc(0.25) within group (order by "LFE305213") as kwartyl1, 
percentile_disc(0.75) within group (order by "LFE305213") as kwartyl3 
from county_facts cf 

--dojazd do pracy w minutach - 3 kwartyl wg kandydat
with all_lfe as (
		select cf."LFE305213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."LFE305213" >= 26.4
		group by pr.candidate, party, cf."LFE305213" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_lfe  
group by candidate, party 
order by sum(vs) desc

--dojazd do pracy w minutach - 3 kwartyl wg partia
with all_lfe as (
		select cf."LFE305213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."LFE305213" >= 26.4
		group by pr.candidate, party, cf."LFE305213" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_lfe  
group by party 
order by sum(vs) desc

--dojazd do pracy w minutach - 1 kwartyl wg kandydat
with all_lfe as (
		select cf."LFE305213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."LFE305213" <= 19.2
		group by pr.candidate, party, cf."LFE305213" 
		order by sum(votes) desc
		)
select candidate, party, sum(vs) 
from all_lfe  
group by candidate, party 
order by sum(vs) desc

--dojazd do pracy w minutach - 1 kwartyl wg kandydat
with all_lfe as (
		select cf."LFE305213", candidate, party, sum(votes) as vs 
		from primary_results pr 
		join county_facts cf on pr.fips =cf.fips 
		where cf."LFE305213" <= 19.2
		group by pr.candidate, party, cf."LFE305213" 
		order by sum(votes) desc
		)
select party, sum(vs) 
from all_lfe  
group by party 
order by sum(vs) desc



select 
"LND110210", "POP060210", "POP715213", "LFE305213", "BPS030214"
from county_facts cf 

select state_abbreviation, sum("VET605213")
from county_facts cf 
group by state_abbreviation, "VET605213"
order by "VET605213" desc

select fips, candidate, votes 
from primary_results pr 
where fips = '17031' 
order by votes desc

select fips, votes_sum 
from sum_votes sv 
where votes_sum = 0