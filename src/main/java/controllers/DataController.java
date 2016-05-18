package controllers;

import javax.inject.Inject;

import ninja.Result;
import ninja.Results;
import utils.DBUtils;

public class DataController {

    @Inject
    private DBUtils dbUtils;

    public Result votes() {
        return returnSqlQueryResultAsJson("select * from openpkw.results;");
    }

    public Result frequency() {
        return returnSqlQueryResultAsJson("select * from openpkw.frequency;");
    }

    public Result protocols() {
        return returnSqlQueryResultAsJson("select * from openpkw.protocols;");
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