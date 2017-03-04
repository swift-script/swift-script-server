import Foundation
import Kitura

let router = Router()

// Handle HTTP GET requests to /
router.get("/") { request, response, next in
    response.send("try? Swift 2017")
    next()
}



router.post("") { request, response, next in
    response.send("try! Swift 2017 Post")
    next()
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8080, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
