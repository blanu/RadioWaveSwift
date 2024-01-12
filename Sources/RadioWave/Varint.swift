//
//  Varint.swift
//
//
//  Created by Dr. Brandon Wiley on 12/31/23.
//

import Foundation

public func compress(_ uncompressed: Data) -> Data
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

public func unpackVarintData(buffer: Data) throws -> Data
{
    guard buffer.count <= 8 else
    {
        throw VarintError.bufferTooBig
    }

    let padding = Data(repeating: 0, count: 8 - buffer.count)

    return padding + buffer
}

public enum VarintError: Error
{
    case bufferTooBig
}
