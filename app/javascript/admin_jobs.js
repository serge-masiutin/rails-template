import { application } from "controllers/application"
import LiveRegionController from "admin/live_region_controller"
import "operations_stream"

application.register("live-region", LiveRegionController)
