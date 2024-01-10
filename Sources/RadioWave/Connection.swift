//
//  Connection.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/31/23.
//

import Foundation

import Datable
import Transmission

public struct Connection<Request: MaybeDatable, Response: MaybeDatable>
{
    let network: Transmission.Connection

    public init(host: String, port: Int) throws
    {
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

        guard let response = Response(data: payload) else
        {
            throw ConnectionError.conversionFailed
        }

        return response
    }

    public func write(_ request: Request) throws
    {
        let payload = request.data

        guard let uncompressed = UInt64(payload.count).maybeNetworkData else
        {
            throw ConnectionError.conversionFailed
        }

        var compressed = self.compress(uncompressed)

        guard let prefix = UInt8(compressed.count).maybeNetworkData else
        {
            throw ConnectionError.conversionFailed
        }

        let data = prefix + compressed + payload

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

    func compress(_ uncompressed: Data) -> Data
    {
        guard uncompressed.count > 0 else
        {
            return uncompressed
        }

        var prefix = 0
        for index in 0..<uncompressed.count
        {
            if uncompressed[index] == 0
            {
                prefix += 1
            }
        }

        return Data(uncompressed[prefix...])
    }
}

public enum ConnectionError: Error
{
    case connectionFailed
    case readFailed
    case writeFailed
    case conversionFailed
}
