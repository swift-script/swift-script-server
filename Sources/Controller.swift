import Foundation
import Kitura
import KituraCORS
import LoggerAPI
import SwiftScript

public class SSController {
    let router: Router

    init() throws {
        router = Router()
        let options = Options()
        let cors = CORS(options: options)

        router.all("/", middleware: StaticFileServer())
        router.post("/", middleware: cors)
        router.post("/", handler: callTranspiler)
    }

    var port: Int {
        return 8080
    }

    var name: String {
        var rnd = 0
        #if os(Linux)
            rnd = random()
        #else
            rnd = Int(arc4random_uniform(UInt32.max))
        #endif
        return "\(Date().timeIntervalSince1970).\(rnd)"
    }

    var filePath: String {
        return "/var/tmp/swiftscript/"
    }

    public func callTranspiler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("POST - /  transpile Value")
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        guard let value = try request.readString() else {
            response.send("could not parse body\n")
            Log.error("request.body: \(request.body)")
            try response.end()
            return
        }

        let baseUrlString = filePath + name
        saveFile(to: baseUrlString, value: value)
        let compiled = compile(baseUrlString)
        if compiled.status != 0 {
            response.send(compiled.text ?? "")
            try response.end()
            return
        }

        Log.verbose("swift: `\(value)`")
        do {
            let message = try transpile(code: value)
            Log.verbose("javascript: `\(message)`")
            response.status(.OK).send(message)
        } catch let e {
            Log.error("`\(value)` -> `\(e)`")
            response.send("\(e)")
        }
        try response.end()
        next()
    }

    func saveFile(to urlString: String, value: String) {
        let url = URL(fileURLWithPath: urlString + ".swift")
        try? value.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    }

    func compile(_ urlString: String) -> (status: Int, text: String?) {
        let url = URL(fileURLWithPath: urlString + ".swift")
        let binaryUrl = URL(fileURLWithPath: urlString)
        let pipe = Pipe()

        #if os(Linux)
            let task = Task()
            task.launchPath = "/home/ubuntu/swift/usr/bin/swiftc"
            task.arguments =  [url.path, "-o", binaryUrl.path]
            task.standardError = pipe
            task.launch()
            task.waitUntilExit()
        #else
            let task = Process()
            task.launchPath = "/bin/sh"
            task.arguments = ["swiftc", url.path, "-o", binaryUrl.path]
            task.standardError = pipe
            task.launch()
            task.waitUntilExit()
        #endif
        try? FileManager.default.removeItem(at: url)
        try? FileManager.default.removeItem(at: binaryUrl)

        guard task.terminationStatus == 0 else {
            let data = pipe.fileHandleForReading.availableData
            let errorString = String(data: data, encoding: .utf8)?
                .replacingOccurrences(of: url.path, with: "")
                .replacingOccurrences(of: "^", with: "") ?? ""
            print(errorString)
            return (-1, errorString)
        }
        return (0, nil)
    }
}
