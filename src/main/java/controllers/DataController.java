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

    public Result votesForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("select * from openpkw.results_district_votes where districtCommitteeId = " + districtId + " order by numberOfVotes desc;");
    }
    
    public Result frequencyForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("select * from openpkw.results_district_frequency where districtCommitteeId = " + districtId + ";");
    }    

    public Result protocolsForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("select * from openpkw.results_district_protocols where districtCommitteeId = " + districtId + ";");
    }    
    
    public Result peripheralCommitteesForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("select * from openpkw.results_district_peripheral_committees where districtCommitteeId = " + districtId + ";");
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