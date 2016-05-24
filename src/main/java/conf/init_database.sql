-- country level

drop view if exists openpkw.results_country_frequency;
create view openpkw.results_country_frequency as 
	select 
		(select sum(vote_number) from openpkw.election_committee_vote) as voters, 
        (select sum(allowed_to_vote) from openpkw.peripheral_committee) as allowedToVote;
        
drop view if exists openpkw.results_country_protocols;
create view openpkw.results_country_protocols as 
	select 
		(select count(*) from openpkw.peripheral_committee) as totalPeripheralCommittees, 
        (select count(*) from openpkw.protocol) as totalProtocols;

drop view if exists openpkw.results_country_votes;
create view openpkw.results_country_votes as
select 
	ec.symbol as electionCommittee,
	sum(ecv.vote_number) as numberOfVotes,
	(select sum(vote_number) from openpkw.election_committee_vote) as totalNumberOfVotes
from 
	openpkw.election_committee_vote ecv
left join
	openpkw.election_committee_district ecd
on 
	ecd.election_committee_district_id = ecv.election_committee_district_id
left join
	openpkw.election_committee ec
on ecd.election_committee_id = ec.election_committee_id
group by ecd.election_committee_id, totalNumberOfVotes
order by numberOfVotes desc;

drop view if exists openpkw.results_country_district_committees;
create view openpkw.results_country_district_committees as
select
	dc.district_committee_id,
	dc.district_committee_number,
    dc.name,
    dca.city,
    (select count(pc.peripheral_committee_id) from openpkw.peripheral_committee pc where pc.district_committee_id = dc.district_committee_id) as numberOfPeripherals,
    (select count(*) from openpkw.election_committee_vote ecv where ecv.election_committee_district_id in (select ecd.election_committee_district_id from openpkw.election_committee_district ecd where ecd.district_committee_id = dc.district_committee_id)) as numberOfReceivedProtocols
from 
	openpkw.district_committee dc
left join
	openpkw.district_committee_address dca
on
	dc.district_committee_address_id = dca.district_committee_address_id;

-- district level

drop view if exists openpkw.results_district_details;
create view openpkw.results_district_details as
select
	district_committee_id as districtCommitteeId,
	name as districtName
from
	openpkw.district_committee;
    
drop view if exists openpkw.results_district_votes;
create view openpkw.results_district_votes as
select 
	dc.district_committee_id as districtCommitteeId,
	ec.symbol as electionCommittee,
	sum(ecv.vote_number) as numberOfVotes,
    (select sum(ecv1.vote_number) from openpkw.election_committee_vote ecv1 where ecv1.election_committee_district_id in (select ecd1.election_committee_district_id from openpkw.election_committee_district ecd1 where ecd.district_committee_id = ecd1.district_committee_id)) as totalNumberOfVotes
from 
	openpkw.election_committee_vote ecv
left join
	openpkw.election_committee_district ecd
on 
	ecd.election_committee_district_id = ecv.election_committee_district_id
left join
	openpkw.election_committee ec
on 
	ecd.election_committee_id = ec.election_committee_id
left join
	openpkw.district_committee dc
on
	dc.district_committee_id = ecd.district_committee_id
group by 
	districtCommitteeId, electionCommittee
order by
	numberOfVotes desc;

drop view if exists openpkw.results_district_frequency;
create view openpkw.results_district_frequency as
select 
	dc.district_committee_id as districtCommitteeId,
    (select sum(allowed_to_vote) from openpkw.peripheral_committee pc where pc.district_committee_id = dc.district_committee_id) as allowedToVote,
    (select sum(ecv.vote_number) from openpkw.election_committee_vote ecv where ecv.election_committee_district_id in (select ecd.election_committee_district_id from openpkw.election_committee_district ecd where ecd.district_committee_id = dc.district_committee_id)) as voters
from
	openpkw.district_committee dc;
       
drop view if exists openpkw.results_district_protocols;
create view openpkw.results_district_protocols as
select 
	dc.district_committee_id as districtCommitteeId,
    (select count(*) from openpkw.peripheral_committee pc where pc.district_committee_id = dc.district_committee_id) as totalPeripheralCommittees,
    (select count(*) from openpkw.protocol p where p.peripheral_committee_id in (select pc.peripheral_committee_id from openpkw.peripheral_committee pc where pc.district_committee_id = dc.district_committee_id)) as totalProtocols
from
	openpkw.district_committee dc;
    
drop view if exists openpkw.results_district_peripheral_committees;
create view openpkw.results_district_peripheral_committees as
select
	pc.district_committee_id as districtCommitteeId,
    pc.territorial_code as territorialCode,
	pc.peripheral_committee_id as peripheralCommitteeId,
    pc.peripheral_committee_number as peripheralCommitteeNumber,
    pc.name as peripheralCommitteeName
from 
	openpkw.peripheral_committee pc;

drop view if exists openpkw.results_district_candidates;
create view openpkw.results_district_candidates as
select
	ecd.district_committee_id as districtCommitteeId,
	ec.long_name as electionCommitteeName,
	c.position_on_list as positionOnList,
	concat(c.name, ' ', c.surname) as candidateName,
	(select 0) as numberOfVotes,
	(select 0) as percentNumberOfVotes,
	(select false) as mandate
from
	openpkw.candidate c
left join
	openpkw.election_committee_district ecd
on
	c.election_committee_district_id = ecd.election_committee_district_id
left join
	openpkw.election_committee ec
on
	ecd.election_committee_id = ec.election_committee_id;    
	
drop view if exists openpkw.results_district_election_committees;
create view openpkw.results_district_election_committees as
select
	ecd.district_committee_id as districtCommitteeId,
	ecd.list_number as listNumber,
    ec.long_name as electionCommitteeName,
    sum(ecv.vote_number) as numberOfVotes,
    (select sum(ecv.vote_number) from openpkw.election_committee_vote ecv where ecv.election_committee_district_id in (select ecd1.election_committee_district_id from openpkw.election_committee_district ecd1 where ecd1.district_committee_id = ecd.district_committee_id)) as totalNumberOfVotes
from
	openpkw.election_committee_district ecd
left join
	openpkw.election_committee ec
on
	ecd.election_committee_id = ec.election_committee_id
left join
	openpkw.election_committee_vote ecv
on
	ecv.election_committee_district_id = ecd.election_committee_district_id
group by
	districtCommitteeId, listNumber, electionCommitteeName;