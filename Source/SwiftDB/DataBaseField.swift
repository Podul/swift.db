//
//  DataBaseField.swift
//  swift.db
//
//  Created by Podul on 2019/11/15.
//  Copyright © 2019 Podul. All rights reserved.
//  数据库字段

import Foundation

protocol CustomDBType: Codable {
    associatedtype CustomType: Codable
    var value: CustomType { set get }
}

extension CustomDBType {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}

// MARK: - <#mark#>
/// 主键，不要加?，Optional
public struct Primary: CustomDBType {
    var value: Int
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(CustomType.self)
    }
}

extension Primary: ExpressibleByIntegerLiteral, CustomStringConvertible {
    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: Int) {
        self.value = value
    }
    
    public var description: String {
        return "\(self.value)"
    }
}

/// 一个带符号的整数，根据值的大小存储在 1、2、3、4、6 或 8 字节中。
/// 对应`Swift`中所有整型`（Int, UInt, Int8 ....）`
public struct Integer: CustomDBType {
    var value: Int
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(CustomType.self)
    }
}

extension Integer: ExpressibleByIntegerLiteral, CustomStringConvertible {
    public init(integerLiteral value: Int) {
        self.value = value
    }
    
    public typealias IntegerLiteralType = Int
    
    public var description: String {
        return "\(self.value)"
    }
}

/// 一个文本字符串，使用数据库编码（UTF-8、UTF-16BE 或 UTF-16LE）存储。
/// 对应`Swift`中字符串`String`
public struct Text: CustomDBType {
    var value: String
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(CustomType.self)
    }
}

extension Text: ExpressibleByStringLiteral, CustomStringConvertible {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.value = value
    }
    
    public var description: String {
        return "\(self.value)"
    }
}

/// 一个浮点值，存储为 8 字节的 IEEE 浮点数字。
/// 对应`Swift`中`Float Double`
public struct Real: CustomDBType {
    var value: Float
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(CustomType.self)
    }
}

extension Real: ExpressibleByFloatLiteral, CustomStringConvertible {
    public typealias FloatLiteralType = Float
    public init(floatLiteral value: Self.FloatLiteralType) {
        self.value = value
    }
    public var description: String {
        return "\(self.value)"
    }
}

// TODO: -
//struct Blob: Codable { }
