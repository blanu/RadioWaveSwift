//
//  Stdio.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/31/23.
//

import Foundation

import Datable
import Transmission

public struct Stdio<Request: MaybeDatable, Response: MaybeDatable>
{
    let stdin: FileHandle
    let stdout: FileHandle

    public init(stdin: FileHandle, stdout: FileHandle) throws
    {
        self.stdin = stdin
        self.stdout = stdout
    }

    public func read() throws -> Response
    {
        guard let prefix = try self.stdin.read(upToCount: 1) else
        {
            throw StdioError.readFailed
        }

        let varintCount = Int(prefix[0])

        guard let compressedBuffer = try self.stdin.read(upToCount: varintCount) else
        {
            throw StdioError.readFailed
        }

        let uncompressedBuffer = try unpackVarintData(buffer: compressedBuffer)

        guard let payloadCount = uncompressedBuffer.maybeNetworkUint64 else
        {
            throw ConnectionError.conversionFailed
        }

        guard let payload = try self.stdin.read(upToCount: Int(payloadCount)) else
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

        var compressed = uncompressed
        while compressed[0] == 0
        {
            compressed = compressed.dropFirst()
        }

        guard let prefix = UInt8(compressed.count).maybeNetworkData else
        {
            throw ConnectionError.conversionFailed
        }

        let data = prefix + compressed + payload

        self.stdout.write(data)
    }

    public func call(_ request: Request) throws -> Response
    {
        try self.write(request)
        return try self.read()
    }

    public func close()
    {
        try? self.stdin.close()
        try? self.stdout.close()
    }
}

public enum StdioError: Error
{
    case connectionFailed
    case readFailed
    case writeFailed
    case conversionFailed
}
