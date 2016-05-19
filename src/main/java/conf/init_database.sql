drop view if exists openpkw.results_frequency;
drop view if exists openpkw.results_protocols;
drop view if exists openpkw.results_votes;
drop view if exists openpkw.results_peripheral_committees;

create view openpkw.results_frequency as 
	select 
		(select sum(vote_number) from openpkw.election_committee_vote) as voters, 
        (select sum(allowed_to_vote) from openpkw.peripheral_committee) as allowedToVote;
        
create view openpkw.results_protocols as 
	select 
		(select count(*) from openpkw.peripheral_committee) as totalPeripheralCommittees, 
        (select count(*) from openpkw.protocol) as totalProtocols;

create view openpkw.results_votes as
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

create view openpkw.results_peripheral_committees as
select
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