import Kitura
import SwiftKueryMySQL
import SwiftKuery
import ObjectMapper
import Foundation
import KituraNet

class MessageService {
    //MARK:- Properties
    var router: Router
    var connection: MySQLConnection
    
    //MARK:- Init
    init(router: Router, connection: MySQLConnection) {
        self.router = router
        self.connection = connection
        router.all(middleware: BodyParser())
        submitMessage()
    }
    
    func submitMessage() {
        var responseStatus: HTTPStatusCode?
        router.post("/SubmitMessage") {request, response, next in
            guard let jsonPayload = Formatter.jsonPayload(request: request) else {
                try response.send("\(HTTPStatusCode.badRequest.rawValue)").end()
                next()
                return
            }
            let messageManager = MessageManager(router: self.router, connection:self.connection)
            messageManager.insertMessage(json: jsonPayload, completion: { response in
                responseStatus = response
            })
            try response.send("\(responseStatus!.rawValue)").end()
            next()
        }
    }
}