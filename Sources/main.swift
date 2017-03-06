import Foundation
import Kitura
import KituraCORS
import SwiftScript
import HeliumLogger
import LoggerAPI

let router = Router()
let options = Options()
let cors = CORS(options: options)
let logger = HeliumLogger(.entry)
Log.logger = logger

router.get("/", middleware: StaticFileServer())

router.post("/", middleware: cors)
router.post("/") { request, response, next in
    guard let value = try request.readString() else {
        response.send("could not parse body\n")
        Log.error("request.body: \(request.body)")
        try response.end()
        return
    }

    Log.verbose("swift: `\(value)`")
    do {
        let message = try transpile(code: value)
        Log.verbose("javascript: `\(message)`")

        response.send(message)
        response.send("\n")
    } catch let e {
        Log.error("`\(value)` -> `\(e)`")
        response.send("\(e)")
    }
    try response.end()
    next()
}

Kitura.addHTTPServer(onPort: 8080, with: router)

Kitura.run()
