-- country level

drop view if exists openpkw.results_country_frequency;
create view openpkw.results_country_frequency as 
    select 
        (select sum(vote_number) from openpkw.ELECTION_COMMITTEE_VOTE) as voters, 
        (select sum(allowed_to_vote) from openpkw.PERIPHERAL_COMMITTEE) as allowedToVote;
        
drop view if exists openpkw.results_country_protocols;
create view openpkw.results_country_protocols as 
    select 
        (select count(*) from openpkw.PERIPHERAL_COMMITTEE) as totalPeripheralCommittees, 
        (select count(*) from openpkw.PROTOCOL) as totalProtocols;

drop view if exists openpkw.results_country_votes;
create view openpkw.results_country_votes as
select 
    ec.symbol as electionCommittee,
    sum(ecv.vote_number) as numberOfVotes,
    (select sum(vote_number) from openpkw.ELECTION_COMMITTEE_VOTE) as totalNumberOfVotes
from 
    openpkw.ELECTION_COMMITTEE_VOTE ecv
join
    openpkw.ELECTION_COMMITTEE_DISTRICT ecd
on 
    ecd.ELECTION_COMMITTEE_DISTRICT_id = ecv.ELECTION_COMMITTEE_DISTRICT_id
join
    openpkw.ELECTION_COMMITTEE ec
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
    (select count(pc.PERIPHERAL_COMMITTEE_id) from openpkw.PERIPHERAL_COMMITTEE pc where pc.district_committee_id = dc.district_committee_id) as numberOfPeripherals,
    (select count(*) from openpkw.ELECTION_COMMITTEE_VOTE ecv where ecv.ELECTION_COMMITTEE_DISTRICT_id in (select ecd.ELECTION_COMMITTEE_DISTRICT_id from openpkw.ELECTION_COMMITTEE_DISTRICT ecd where ecd.district_committee_id = dc.district_committee_id)) as numberOfReceivedProtocols
from 
    openpkw.DISTRICT_COMMITTEE dc
join
    openpkw.DISTRICT_COMMITTEE_ADDRESS dca
on
    dc.district_committee_address_id = dca.district_committee_address_id;

-- district level

drop view if exists openpkw.results_district_details;
create view openpkw.results_district_details as
select
    district_committee_id as districtCommitteeId,
    name as districtName
from
    openpkw.DISTRICT_COMMITTEE;
    
drop view if exists openpkw.results_district_votes;
create view openpkw.results_district_votes as
select 
    dc.district_committee_id as districtCommitteeId,
    ec.symbol as electionCommittee,
    sum(ecv.vote_number) as numberOfVotes,
    (select sum(ecv1.vote_number) from openpkw.ELECTION_COMMITTEE_VOTE ecv1 where ecv1.ELECTION_COMMITTEE_DISTRICT_id in (select ecd1.ELECTION_COMMITTEE_DISTRICT_id from openpkw.ELECTION_COMMITTEE_DISTRICT ecd1 where ecd.district_committee_id = ecd1.district_committee_id)) as totalNumberOfVotes
from 
    openpkw.ELECTION_COMMITTEE_VOTE ecv
join
    openpkw.ELECTION_COMMITTEE_DISTRICT ecd
on 
    ecd.ELECTION_COMMITTEE_DISTRICT_id = ecv.ELECTION_COMMITTEE_DISTRICT_id
join
    openpkw.ELECTION_COMMITTEE ec
on 
    ecd.election_committee_id = ec.election_committee_id
join
    openpkw.DISTRICT_COMMITTEE dc
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
    (select sum(allowed_to_vote) from openpkw.PERIPHERAL_COMMITTEE pc where pc.district_committee_id = dc.district_committee_id) as allowedToVote,
    (select sum(ecv.vote_number) from openpkw.ELECTION_COMMITTEE_VOTE ecv where ecv.ELECTION_COMMITTEE_DISTRICT_id in (select ecd.ELECTION_COMMITTEE_DISTRICT_id from openpkw.ELECTION_COMMITTEE_DISTRICT ecd where ecd.district_committee_id = dc.district_committee_id)) as voters
from
    openpkw.DISTRICT_COMMITTEE dc;
       
drop view if exists openpkw.results_district_protocols;
create view openpkw.results_district_protocols as
select 
    dc.district_committee_id as districtCommitteeId,
    (select count(*) from openpkw.PERIPHERAL_COMMITTEE pc where pc.district_committee_id = dc.district_committee_id) as totalPeripheralCommittees,
    (select count(*) from openpkw.PROTOCOL p where p.PERIPHERAL_COMMITTEE_id in (select pc.PERIPHERAL_COMMITTEE_id from openpkw.PERIPHERAL_COMMITTEE pc where pc.district_committee_id = dc.district_committee_id)) as totalProtocols
from
    openpkw.DISTRICT_COMMITTEE dc;
    
drop view if exists openpkw.results_district_PERIPHERAL_COMMITTEEs;
create view openpkw.results_district_PERIPHERAL_COMMITTEEs as
select
    pc.district_committee_id as districtCommitteeId,
    pc.territorial_code as territorialCode,
    pc.PERIPHERAL_COMMITTEE_id as peripheralCommitteeId,
    pc.PERIPHERAL_COMMITTEE_number as peripheralCommitteeNumber,
    pc.name as peripheralCommitteeName
from 
    openpkw.PERIPHERAL_COMMITTEE pc;

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
    openpkw.CANDIDATE c
join
    openpkw.ELECTION_COMMITTEE_DISTRICT ecd
on
    c.ELECTION_COMMITTEE_DISTRICT_id = ecd.ELECTION_COMMITTEE_DISTRICT_id
join
    openpkw.ELECTION_COMMITTEE ec
on
    ecd.election_committee_id = ec.election_committee_id;    
    
drop view if exists openpkw.results_district_election_committees;
create view openpkw.results_district_election_committees as
select
    ecd.district_committee_id as districtCommitteeId,
    ecd.list_number as listNumber,
    ec.long_name as electionCommitteeName,
    sum(ecv.vote_number) as numberOfVotes,
    (select sum(ecv.vote_number) from openpkw.ELECTION_COMMITTEE_VOTE ecv where ecv.ELECTION_COMMITTEE_DISTRICT_id in (select ecd1.ELECTION_COMMITTEE_DISTRICT_id from openpkw.ELECTION_COMMITTEE_DISTRICT ecd1 where ecd1.district_committee_id = ecd.district_committee_id)) as totalNumberOfVotes
from
    openpkw.ELECTION_COMMITTEE_DISTRICT ecd
join
    openpkw.ELECTION_COMMITTEE ec
on
    ecd.election_committee_id = ec.election_committee_id
join
    openpkw.ELECTION_COMMITTEE_VOTE ecv
on
    ecv.ELECTION_COMMITTEE_DISTRICT_id = ecd.ELECTION_COMMITTEE_DISTRICT_id
group by
    districtCommitteeId, listNumber, electionCommitteeName;