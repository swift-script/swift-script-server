import Foundation
import Kitura
import HeliumLogger
import LoggerAPI

do {
    // HeliumLogger disables all buffering on stdout
    HeliumLogger.use(.entry)
    let controller = try SSController()
    Kitura.addHTTPServer(onPort: controller.port, with: controller.router)
    // Start Kitura-Starter server
    Kitura.run()
} catch let error {
    Log.error(error.localizedDescription)
}
