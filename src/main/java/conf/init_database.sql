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

drop procedure if exists openpkw.getDistrictDetails;
create procedure openpkw.getDistrictDetails(in districtCommitteeId int)
begin
	select
		name as districtName
	from
		openpkw.DISTRICT_COMMITTEE
	where
		district_committee_id = districtCommitteeId;
end;
    
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

drop procedure if exists openpkw.getDistrictProtocols;
create procedure openpkw.getDistrictProtocols(in districtCommitteeId int)
begin
select 
    (select count(*) from openpkw.PERIPHERAL_COMMITTEE pc where pc.district_committee_id = districtCommitteeId) as totalPeripheralCommittees,
    (select count(*) from openpkw.PROTOCOL p where p.PERIPHERAL_COMMITTEE_id in (select pc.PERIPHERAL_COMMITTEE_id from openpkw.PERIPHERAL_COMMITTEE pc where pc.district_committee_id = districtCommitteeId)) as totalProtocols;
end;
    
drop view if exists openpkw.results_district_frequency;
create view openpkw.results_district_frequency as
select 
    dc.district_committee_id as districtCommitteeId,
    (select sum(allowed_to_vote) from openpkw.PERIPHERAL_COMMITTEE pc where pc.district_committee_id = dc.district_committee_id) as allowedToVote,
    (select sum(ecv.vote_number) from openpkw.ELECTION_COMMITTEE_VOTE ecv where ecv.ELECTION_COMMITTEE_DISTRICT_id in (select ecd.ELECTION_COMMITTEE_DISTRICT_id from openpkw.ELECTION_COMMITTEE_DISTRICT ecd where ecd.district_committee_id = dc.district_committee_id)) as voters
from
    openpkw.DISTRICT_COMMITTEE dc;
       
    
drop procedure if exists openpkw.getDistrictCandidates;
create procedure openpkw.getDistrictCandidates(in districtCommitteeId int)
begin
	declare _totalNumberOfVotesInDistrict int default 0;
    set _totalNumberOfVotesInDistrict = (
    	select sum(CANDIDATES_VOTES_NUMBER) from openpkw.VOTE where PROTOCOL_ID in (
			select 	p.PROTOCOL_ID from  openpkw.PROTOCOL p where p.PERIPHERAL_COMMITTEE_ID in (
				select peripheral_committee_id from openpkw.PERIPHERAL_COMMITTEE where DISTRICT_COMMITTEE_ID = districtCommitteeId
			)
		)
	);
		
	select
		ec.long_name as electionCommitteeName,
		c.position_on_list as positionOnList,
		c.id as candidateId,
		concat(c.name, ' ', c.surname) as candidateName,
		sum(v.CANDIDATES_VOTES_NUMBER) as numberOfVotes,
		_totalNumberOfVotesInDistrict as totalNumberOfVotes,
		(select false) as mandate   
	from
		openpkw.VOTE v 
	left join
		openpkw.CANDIDATE c
	on
		v.CANDIDATE_ID = c.ID
	join
		openpkw.ELECTION_COMMITTEE_DISTRICT ecd
	on
		c.ELECTION_COMMITTEE_DISTRICT_ID = ecd.ELECTION_COMMITTEE_DISTRICT_ID
	join
		openpkw.ELECTION_COMMITTEE ec
	on
		ecd.election_committee_id = ec.election_committee_id
	where
		ecd.DISTRICT_COMMITTEE_ID = districtCommitteeId
	group by
		electionCommitteeName, positionOnList, candidateId, candidateName, mandate
	order by
		numberOfVotes desc;
end;    

drop procedure if exists openpkw.getDistrictElectionCommittees;
create procedure openpkw.getDistrictElectionCommittees(in districtCommitteeId int)
begin
	declare _totalNumberOfVotesInDistrict int default 0;
    set _totalNumberOfVotesInDistrict = (
    	select sum(CANDIDATES_VOTES_NUMBER) from openpkw.VOTE where PROTOCOL_ID in (
			select 	p.PROTOCOL_ID from  openpkw.PROTOCOL p where p.PERIPHERAL_COMMITTEE_ID in (
				select peripheral_committee_id from openpkw.PERIPHERAL_COMMITTEE where DISTRICT_COMMITTEE_ID = districtCommitteeId
			)
		)
	);	
	
	select 
		ecd.list_number as listNumber,
		ec.long_name as electionCommitteeName,
		sum(ecv.vote_number) as numberOfVotes,
        2 as totalNumberOfVotes
	from 
		openpkw.ELECTION_COMMITTEE_VOTE ecv 
	left join
		openpkw.ELECTION_COMMITTEE_DISTRICT ecd
	on
		ecv.ELECTION_COMMITTEE_DISTRICT_ID = ecd.ELECTION_COMMITTEE_DISTRICT_ID
	left join
		openpkw.ELECTION_COMMITTEE ec
	on
		ecd.ELECTION_COMMITTEE_ID = ec.ELECTION_COMMITTEE_ID
	where
		ecd.DISTRICT_COMMITTEE_ID = districtCommitteeId
	group by
		listNumber, electionCommitteeName, totalNumberOfVotes
	order by
		numberOfVotes desc;
end;     
    
drop view if exists openpkw.results_district_peripheral_committees;
create view openpkw.results_district_peripheral_committees as
select
    pc.district_committee_id as districtCommitteeId,
    pc.territorial_code as territorialCode,
    pc.peripheral_committee_id as peripheralCommitteeId,
    pc.peripheral_committee_number as peripheralCommitteeNumber,
    pc.name as peripheralCommitteeName,
    pc.allowed_to_vote as allowedToVote,
    p.cards_given as cardsGiven,
    p.invalid_votes as invalidVotes
from 
    openpkw.PERIPHERAL_COMMITTEE pc
left join
	openpkw.Protocol p
on
	pc.peripheral_committee_id = p.peripheral_committee_id;
    
    
-- periphery level

drop procedure if exists openpkw.getPeripheryDetails;
create procedure openpkw.getPeripheryDetails(in peripheralCommitteeId int)
begin
	select
		pc.peripheral_committee_number as peripheralCommitteeNumber,
		pc.name as peripheralCommitteeName,
        pc.territorial_code as territorialCode
	from
		openpkw.PERIPHERAL_COMMITTEE pc
	where
		pc.peripheral_committee_id = peripheralCommitteeId;
end;

drop procedure if exists openpkw.getPeripheryFrequency;
create procedure openpkw.getPeripheryFrequency(in peripheralCommitteeId int)
begin
	select
		(select sum(ecv.vote_number) from openpkw.ELECTION_COMMITTEE_VOTE ecv where ecv.PROTOCOL_ID in (select p.protocol_id from openpkw.PROTOCOL p where p.peripheral_committee_id = peripheralCommitteeId)) as voters,
	    (select pc.allowed_to_vote from openpkw.PERIPHERAL_COMMITTEE pc where pc.peripheral_committee_id = peripheralCommitteeId) as allowedToVote;
end;

drop procedure if exists openpkw.getPeripheryVotes;
create procedure openpkw.getPeripheryVotes(in peripheralCommitteeId int)
begin
	select 
		ec.symbol as electionCommittee,
		ecv.vote_number as numberOfVotes,
		(select sum(ecv1.vote_number) from openpkw.ELECTION_COMMITTEE_VOTE ecv1 where PROTOCOL_ID = (select p.PROTOCOL_ID from openpkw.PROTOCOL p where p.PERIPHERAL_COMMITTEE_ID = peripheralCommitteeId)) as totalNumberOfVotes
	from 
		openpkw.ELECTION_COMMITTEE_VOTE ecv 
	left join
		openpkw.ELECTION_COMMITTEE_DISTRICT ecd
	on
		ecv.ELECTION_COMMITTEE_DISTRICT_ID = ecd.ELECTION_COMMITTEE_DISTRICT_ID
	left join
		openpkw.ELECTION_COMMITTEE ec
	on
		ecd.ELECTION_COMMITTEE_ID = ec.ELECTION_COMMITTEE_ID
	where 
		ecv.PROTOCOL_ID = (select p.PROTOCOL_ID from openpkw.PROTOCOL p where p.PERIPHERAL_COMMITTEE_ID = peripheralCommitteeId)
	order by
		numberOfVotes desc;
end; 

drop procedure if exists openpkw.getPeripheryElectionCommittees;
create procedure openpkw.getPeripheryElectionCommittees(in peripheralCommitteeId int)
begin
	select 
		ecd.list_number as listNumber,
		ec.long_name as electionCommitteeName,
		ecv.vote_number as numberOfVotes,
		(select sum(ecv1.vote_number) from openpkw.ELECTION_COMMITTEE_VOTE ecv1 where PROTOCOL_ID = (select p.PROTOCOL_ID from openpkw.PROTOCOL p where p.PERIPHERAL_COMMITTEE_ID = peripheralCommitteeId)) as totalNumberOfVotes
	from 
		openpkw.ELECTION_COMMITTEE_VOTE ecv 
	left join
		openpkw.ELECTION_COMMITTEE_DISTRICT ecd
	on
		ecv.ELECTION_COMMITTEE_DISTRICT_ID = ecd.ELECTION_COMMITTEE_DISTRICT_ID
	left join
		openpkw.ELECTION_COMMITTEE ec
	on
		ecd.ELECTION_COMMITTEE_ID = ec.ELECTION_COMMITTEE_ID
	where 
		ecv.PROTOCOL_ID = (select p.PROTOCOL_ID from openpkw.PROTOCOL p where p.PERIPHERAL_COMMITTEE_ID = peripheralCommitteeId)
	order by
		numberOfVotes desc;
end; 

drop procedure if exists openpkw.getPeripheryCandidates;
create procedure openpkw.getPeripheryCandidates(in peripheralCommitteeId int)
begin
	select
		ec.long_name as electionCommitteeName,
		c.position_on_list as positionOnList,
		c.id as candidateId,
		concat(c.name, ' ', c.surname) as candidateName,
		v.CANDIDATES_VOTES_NUMBER as numberOfVotes,
		(select sum(CANDIDATES_VOTES_NUMBER) from openpkw.VOTE where PROTOCOL_ID = (select p.PROTOCOL_ID from openpkw.PROTOCOL p where p.PERIPHERAL_COMMITTEE_ID = peripheralCommitteeId)) as totalNumberOfVotes,
		(select false) as mandate   
	from
		openpkw.VOTE v 
	left join
		openpkw.CANDIDATE c
	on
		v.CANDIDATE_ID = c.ID
		join
			openpkw.ELECTION_COMMITTEE_DISTRICT ecd
		on
			c.ELECTION_COMMITTEE_DISTRICT_id = ecd.ELECTION_COMMITTEE_DISTRICT_id
		join
			openpkw.ELECTION_COMMITTEE ec
		on
			ecd.election_committee_id = ec.election_committee_id
	where
		v.PROTOCOL_ID = (select p.PROTOCOL_ID from openpkw.PROTOCOL p where p.PERIPHERAL_COMMITTEE_ID = peripheralCommitteeId)
	order by
		numberOfVotes desc;
end;