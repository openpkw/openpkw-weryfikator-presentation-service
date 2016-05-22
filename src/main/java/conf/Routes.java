package conf;

import ninja.AssetsController;
import ninja.Router;
import ninja.application.ApplicationRoutes;
import controllers.GuiController;
import controllers.DataController;

public class Routes implements ApplicationRoutes {

    @Override
    public void init(Router router) {

        router.GET().route("/").with(GuiController.class, "country");
        router.GET().route("/district/{districtId}").with(GuiController.class, "district");

        router.GET().route("/data/country/votes").with(DataController.class, "votesForCountry");
        router.GET().route("/data/country/frequency").with(DataController.class, "frequencyForCountry");
        router.GET().route("/data/country/protocols").with(DataController.class, "protocolsForCountry");
        router.GET().route("/data/country/districtCommittees").with(DataController.class, "districtCommitteesForCountry");

        router.GET().route("/data/district/{districtId}").with(DataController.class, "districtDetails");
        router.GET().route("/data/district/{districtId}/votes").with(DataController.class, "votesForDistrict");
        router.GET().route("/data/district/{districtId}/frequency").with(DataController.class, "frequencyForDistrict");
        router.GET().route("/data/district/{districtId}/protocols").with(DataController.class, "protocolsForDistrict");
        router.GET().route("/data/district/{districtId}/electionCommittees").with(DataController.class, "electionCommitteesForDistrict");
        router.GET().route("/data/district/{districtId}/candidates").with(DataController.class, "candidatesForDistrict");
        router.GET().route("/data/district/{districtId}/peripheralCommittees").with(DataController.class, "peripheralCommitteesForDistrict");
        
        router.GET().route("/assets/webjars/{fileName: .*}").with(AssetsController.class, "serveWebJars");
        router.GET().route("/assets/{fileName: .*}").with(AssetsController.class, "serveStatic");

        router.GET().route("/.*").with(GuiController.class, "country");
    }
}