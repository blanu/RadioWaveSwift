//
//  TransmisisonFile.swift
//
//
//  Created by Dr. Brandon Wiley on 1/15/24.
//

import Foundation

import Transmission
import TransmissionBase

public class TransmissionFile: BaseConnection
{
    let handle: FileHandle

    public init(handle: FileHandle)
    {
        self.handle = handle

        super.init(id: Int(handle.fileDescriptor))! // FIXME - fix this in TransmissionBase
    }

    override public func networkRead(size: Int) throws -> Data
    {
        var totalData = Data()
        while totalData.count < size
        {
            let leftToRead = size - totalData.count

            guard let data = try self.handle.read(upToCount: leftToRead) else
            {
                throw TransmissionFileError.readFailed
            }

            totalData += data
        }

        return totalData
    }

    override public func networkWrite(data: Data) throws
    {
        try self.handle.write(contentsOf: data)
    }

    override public func close()
    {
        do
        {
            try self.handle.close()
        }
        catch
        {
        }
    }
}

public enum TransmissionFileError: Error
{
    case readFailed
}
