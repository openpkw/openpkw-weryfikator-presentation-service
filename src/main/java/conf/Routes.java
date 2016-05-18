package conf;

import ninja.AssetsController;
import ninja.Router;
import ninja.application.ApplicationRoutes;
import controllers.GuiController;
import controllers.DataController;

public class Routes implements ApplicationRoutes {

    @Override
    public void init(Router router) {

        router.GET().route("/").with(GuiController.class, "index");

        router.GET().route("/data/votes").with(DataController.class, "votes");
        router.GET().route("/data/frequency").with(DataController.class, "frequency");
        router.GET().route("/data/protocols").with(DataController.class, "protocols");

        router.GET().route("/assets/webjars/{fileName: .*}").with(AssetsController.class, "serveWebJars");
        router.GET().route("/assets/{fileName: .*}").with(AssetsController.class, "serveStatic");

        router.GET().route("/.*").with(GuiController.class, "index");
    }
}