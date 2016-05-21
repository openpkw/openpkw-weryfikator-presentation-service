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
        return returnSqlQueryResultAsJson("select * from openpkw.results_votes;");
    }

    public Result frequencyForCountry() {
        return returnSqlQueryResultAsJson("select * from openpkw.results_frequency;");
    }

    public Result protocolsForCountry() {
        return returnSqlQueryResultAsJson("select * from openpkw.results_protocols;");
    }

    public Result peripheralCommitteesForCountry() {
        return returnSqlQueryResultAsJson("select * from openpkw.results_peripheral_committees;");
    }

    public Result votesForDistrict(@PathParam("districtId") int districtId) {
        return returnSqlQueryResultAsJson("select * from openpkw.results_votes_district where districtCommitteeId = " + districtId + " order by numberOfVotes desc;");
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