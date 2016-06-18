package controllers;

import javax.inject.Inject;

import ninja.Result;
import ninja.Results;
import ninja.params.PathParam;
import utils.DBUtils;

public class DataController {

    @Inject
    private DBUtils dbUtils;

    public Result votesForCountry() {
        return returnSqlQueryResultAsJson("select * from openpkw.results_country_votes;");
    }

    public Result frequencyForCountry() {
        return returnSqlQueryResultAsJson("select * from openpkw.results_country_frequency;");
    }

    public Result protocolsForCountry() {
        return returnSqlQueryResultAsJson("select * from openpkw.results_country_protocols;");
    }

    public Result districtCommitteesForCountry() {
        return returnSqlQueryResultAsJson("select * from openpkw.results_country_district_committees;");
    }


    
    public Result districtDetails(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("call openpkw.getDistrictDetails(" + districtId + ");");
    }

    public Result votesForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("select * from openpkw.results_district_votes where districtCommitteeId = " + districtId + " order by numberOfVotes desc;");
    }

    public Result frequencyForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("select * from openpkw.results_district_frequency where districtCommitteeId = " + districtId + ";");
    }

    public Result protocolsForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("call openpkw.getDistrictProtocols(" + districtId + ");");
    }

    public Result peripheralCommitteesForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("select * from openpkw.results_district_peripheral_committees where districtCommitteeId = " + districtId + ";");
    }

    public Result candidatesForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("call openpkw.getDistrictCandidates(" + districtId + ");");
    }

    public Result electionCommitteesForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("call openpkw.getDistrictElectionCommittees(" + districtId + ");");
    }

    public Result peripheryDetails(@PathParam("peripheryId") int peripheryId) {
        return returnSqlQueryResultAsJson("call openpkw.getPeripheryDetails(" + peripheryId + ");");
    }

    public Result votesForPeriphery(@PathParam("peripheryId") int peripheryId) {
        return returnSqlQueryResultAsJson("call openpkw.getPeripheryVotes(" + peripheryId + ");");
    }

    public Result frequencyForPeriphery(@PathParam("peripheryId") int peripheryId) {
        return returnSqlQueryResultAsJson("call openpkw.getPeripheryFrequency(" + peripheryId + ");");
    }

    public Result candidatesForPeriphery(@PathParam("peripheryId") int peripheryId) {
        return returnSqlQueryResultAsJson("call openpkw.getPeripheryCandidates(" + peripheryId + ");");
    }

    public Result electionCommitteesForPeriphery(@PathParam("peripheryId") int peripheryId) {
        return returnSqlQueryResultAsJson("call openpkw.getPeripheryElectionCommittees(" + peripheryId + ");");
    }
    
    

    private Result returnSqlQueryResultAsJson(String sqlQuery) {
        try {
            String jsonResult = dbUtils.executeQueryAndReturnJSON(sqlQuery);
            return Results.text().render(jsonResult);
        } catch (Exception ex) {
            ex.printStackTrace();
            return Results.status(500).render("Failed to fetch data from the database: " + ex.getMessage());
        }
    }
}