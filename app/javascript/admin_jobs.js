import { application } from "controllers/application"
import LiveRegionController from "admin/live_region_controller"

application.register("live-region", LiveRegionController)
