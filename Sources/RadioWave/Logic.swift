//
//  Logic.swift
//
//
//  Created by Dr. Brandon Wiley on 1/7/24.
//

import Foundation

import Datable

public protocol Logic
{
    associatedtype Request
    associatedtype Response

    func service(_ request: Request) throws -> Response
}
