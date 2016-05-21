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

        router.GET().route("/data/votes").with(DataController.class, "votesForCountry");
        router.GET().route("/data/frequency").with(DataController.class, "frequencyForCountry");
        router.GET().route("/data/protocols").with(DataController.class, "protocolsForCountry");
        router.GET().route("/data/peripheralCommittees").with(DataController.class, "peripheralCommitteesForCountry");

        router.GET().route("/data/votes/district/{districtId}").with(DataController.class, "votesForDistrict");
        router.GET().route("/data/frequency/district/{districtId}").with(DataController.class, "frequencyForDistrict");
        router.GET().route("/data/protocols/district/{districtId}").with(DataController.class, "protocolsForDistrict");
        
        router.GET().route("/assets/webjars/{fileName: .*}").with(AssetsController.class, "serveWebJars");
        router.GET().route("/assets/{fileName: .*}").with(AssetsController.class, "serveStatic");

        router.GET().route("/.*").with(GuiController.class, "country");
    }
}