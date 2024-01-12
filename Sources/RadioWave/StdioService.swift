//
//  StdioService.swift
//
//
//  Created by Dr. Brandon Wiley on 1/7/24.
//

import Foundation
import Logging

import Datable

public struct StdioService<Request: MaybeDatable, Response: MaybeDatable, Handler: Logic> where Handler.Request == Request, Handler.Response == Response
{
    let stdio: Stdio<Response, Request> // Yes, these are reversed here, because we are on the server side instead of the client side.
    let handler: Handler
    let logger: Logger

    public init(handler: Handler, logger: Logger) throws
    {
        self.handler = handler
        self.logger = logger

        self.stdio = Stdio<Response, Request>(logger: logger)

        try self.service()
    }

    func service() throws
    {
        while true
        {
            let request = try stdio.read()
            let response = try handler.service(request)
            try stdio.write(response)
        }
    }
}
