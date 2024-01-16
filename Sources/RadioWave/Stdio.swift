//
//  Stdio.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/31/23.
//

import Foundation
import Logging

import Daydream
import Transmission

public struct Stdio<Request: Daydreamable, Response: Daydreamable>
{
    let logger: Logger
    let stdin: Transmission.Connection
    let stdout: Transmission.Connection

    public init(logger: Logger)
    {
        self.init(stdin: FileHandle.standardInput, stdout: FileHandle.standardOutput, logger: logger)
    }

    public init(stdin: FileHandle, stdout: FileHandle, logger: Logger)
    {
        self.stdin = TransmissionFile(handle: stdin)
        self.stdout = TransmissionFile(handle: stdout)
        self.logger = logger
    }

    public func read() throws -> Response
    {
        self.logger.trace("Stdio.read()")

        let response = try Response(daydream: self.stdin)

        return response
    }

    public func write(_ request: Request) throws
    {
        try request.saveDaydream(self.stdout)
    }

    public func call(_ request: Request) throws -> Response
    {
        try self.write(request)
        return try self.read()
    }

    public func close()
    {
        self.stdin.close()
        self.stdout.close()
    }
}

public enum StdioError: Error
{
    case connectionFailed
    case readFailed
    case writeFailed
    case conversionFailed
}
