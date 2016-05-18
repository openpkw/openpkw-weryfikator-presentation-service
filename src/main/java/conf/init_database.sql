drop view if exists openpkw.frequency;
drop view if exists openpkw.protocols;
drop view if exists openpkw.results;

create view openpkw.frequency as 
	select 
		(select sum(vote_number) from openpkw.election_committee_vote) as voters, 
        (select sum(allowed_to_vote) from openpkw.peripheral_committee) as allowedToVote;
        
create view openpkw.protocols as 
	select 
		(select count(*) from openpkw.peripheral_committee) as totalPeripheralCommittees, 
        (select count(*) from openpkw.protocol) as totalProtocols;

create view openpkw.results as
select 
	ec.symbol as electionCommittee,
	sum(ecv.vote_number) as numberOfVotes
from 
	openpkw.election_committee_vote ecv
left join
	openpkw.election_committee_district ecd
on 
	ecd.election_committee_district_id = ecv.election_committee_district_id
left join
	openpkw.election_committee ec
on ecd.election_committee_id = ec.election_committee_id
group by ecd.election_committee_id
order by numberOfVotes desc;