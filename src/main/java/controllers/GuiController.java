package controllers;

import ninja.Result;
import ninja.Results;
import ninja.params.PathParam;

import com.google.inject.Singleton;

@Singleton
public class GuiController {

    public Result country() {
        return Results.html();
    }
    
    public Result district(@PathParam("districtId") int districtId) {
        Result result = Results.html();
        result.render("districtCommitteeId", districtId);
        return result;
    }
    
    public Result periphery(@PathParam("peripheryId") int peripheryId) {
        Result result = Results.html();
        result.render("peripheralCommitteeId", peripheryId);
        return result;
    }    
}