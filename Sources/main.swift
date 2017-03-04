import Foundation
import Kitura
import SwiftScript

let router = Router()


router.get("/", middleware: StaticFileServer())

router.post("/") { request, response, next in
    guard let value = try request.readString() else {
        response.send(status: .badRequest).send("; needs body\n")
        try response.end()
        return
    }

    let message = try transpile(code: value)
    response.send("Your Input was : \(value)\n")
    response.send(message)
    response.send("\n")
    try response.end()
    next()
}

router.error { request, response, next in

}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8080, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
