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

    override public func unsafeRead(size: Int) -> Data?
    {
        var totalData = Data()
        while totalData.count < size
        {
            let leftToRead = size - totalData.count

            do
            {
                guard let data = try self.handle.read(upToCount: leftToRead) else
                {
                    return nil
                }

                totalData += data
            }
            catch
            {
                return nil
            }
        }

        return totalData
    }

    override public func write(data: Data) -> Bool
    {
        do
        {
            try self.handle.write(contentsOf: data)
            return true
        }
        catch
        {
            return false
        }
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
