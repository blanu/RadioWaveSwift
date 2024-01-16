//
//  Connection.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/31/23.
//

import Foundation
import Logging

import Daydream
import Transmission
import SwiftHexTools

public struct Connection<Request: Daydreamable, Response: Daydreamable>
{
    let network: Transmission.Connection
    let logger: Logger

    public init(host: String, port: Int, logger: Logger) throws
    {
        self.logger = logger

        guard let network = TCPConnection(host: host, port: port) else
        {
            throw ConnectionError.connectionFailed
        }

        self.network = network
    }

    public func read() throws -> Response
    {
        return try Response(daydream: self.network)
    }

    public func write(_ request: Request) throws
    {
        try request.saveDaydream(self.network)
    }

    public func call(_ request: Request) throws -> Response
    {
        try self.write(request)
        return try self.read()
    }

    public func close()
    {
        self.network.close()
    }
}

public enum ConnectionError: Error
{
    case connectionFailed
    case readFailed
    case writeFailed
    case conversionFailed
}
