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
        guard let prefix = self.network.read(size: 1) else
        {
            throw ConnectionError.readFailed
        }

        let varintCount = Int(prefix[0])

        guard let compressedBuffer = self.network.read(size: varintCount) else
        {
            throw ConnectionError.readFailed
        }

        let uncompressedBuffer = try unpackVarintData(buffer: compressedBuffer)

        guard let payloadCount = uncompressedBuffer.maybeNetworkUint64 else
        {
            throw ConnectionError.conversionFailed
        }

        guard let payload = self.network.read(size: Int(payloadCount)) else
        {
            throw ConnectionError.readFailed
        }

        let response = try Response(daydream: payload)

        return response
    }

    public func write(_ request: Request) throws
    {
        let payload = request.daydream

        guard let uncompressed = UInt64(payload.count).maybeNetworkData else
        {
            throw ConnectionError.conversionFailed
        }

        let compressed = compress(uncompressed)

        guard let prefix = UInt8(compressed.count).maybeNetworkData else
        {
            throw ConnectionError.conversionFailed
        }

        logger.trace("prefix (\(prefix.count)) - \(prefix.hex)")
        logger.trace("compressed (\(compressed.count)) - \(compressed.hex)")
        logger.trace("payload (\(payload.count)) - \(payload.hex)")

        let data = prefix + compressed + payload

        logger.trace("writing (\(data.count)) - \(data.hex)")

        guard self.network.write(data: data) else
        {
            throw ConnectionError.writeFailed
        }
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
