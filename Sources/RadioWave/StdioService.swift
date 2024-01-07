//
//  StdioService.swift
//
//
//  Created by Dr. Brandon Wiley on 1/7/24.
//

import Foundation

import Datable

public struct StdioService<Request: MaybeDatable, Response: MaybeDatable, Handler: Logic> where Handler.Request == Request, Handler.Response == Response
{
    let stdio = Stdio<Response, Request>() // Yes, these are reversed here, because we are on the server side instead of the client side.
    let handler: Handler

    public init(handler: Handler) throws
    {
        self.handler = handler

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
