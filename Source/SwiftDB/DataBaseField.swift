//
//  DataBaseField.swift
//  swift.db
//
//  Created by Podul on 2019/11/15.
//  Copyright © 2019 Podul. All rights reserved.
//  数据库字段（自定义类型）

import Foundation



// MARK: - <#mark#>
extension DB {

    /// 主键，加了`?<Optional类型>`号也是`NOTNULL`
     public struct Primary: CustomDBType {
        public var value: Int
        
        public init(_ value: Int) {
            self.value = value
        }
    }

    /// 一个带符号的整数，根据值的大小存储在 1、2、3、4、6 或 8 字节中。
    /// 对应`Swift`中所有整型`（Int, UInt, Int8 ....）`
    public struct Integer: CustomDBType {
        public var value: Int
        
        public init(_ value: Int) {
            self.value = value
        }
    }

    /// 一个文本字符串，使用数据库编码（UTF-8、UTF-16BE 或 UTF-16LE）存储。
    /// 对应`Swift`中字符串`String`
    public struct Text: CustomDBType {
        public var value: String
        
        public init(_ value: String) {
            self.value = value
        }
    }

    /// 一个浮点值，存储为 8 字节的 IEEE 浮点数字。
    /// 对应`Swift`中`Float Double`
    public struct Real: CustomDBType {
        public var value: Double
        
        public init(_ value: Double) {
            self.value = value
        }
    }


    /// 一个 blob 数据，完全根据它的输入存储。
    /// 对应`Swift`中`Data`
    public struct Blob: CustomDBType {
        public var value: Data
        
        public init(_ value: Data) {
            self.value = value
        }
    }
    
    public struct Bool: CustomDBType {
        public var value: Swift.Bool
        
        public init(_ value: Swift.Bool) {
            self.value = value
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(Swift.Bool.self) {
                self.value = value
            }else if let value = try? container.decode(Int.self) {
                self.value = Swift.Bool(truncating: NSNumber(value: value))
            }else {
                self.value = Swift.Bool(try container.decode(String.self)) ?? false
            }
        }
    }

}

// MARK: - <#mark#>
extension DB.Primary: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: Int) {
        self.value = value
    }
}

extension DB.Integer: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: Int) {
        self.value = value
    }
}

extension DB.Text: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.value = value
    }
}

extension DB.Real: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    public init(floatLiteral value: Self.FloatLiteralType) {
        self.value = value
    }
}

extension DB.Bool: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Swift.Bool
    public init(booleanLiteral value: Self.BooleanLiteralType) {
        self.value = value
    }
}


// MARK: - <#mark#>
extension Int {
    public init(_ value: DB.Primary) {
        self.init(value.value)
    }
    
    public init (_ value: DB.Integer) {
        self.init(value.value)
    }
}

extension String {
    public init(_ value: DB.Text) {
        self.init(value.value)
    }
}

extension Double {
    public init(_ value: DB.Real) {
        self.init(value.value)
    }
}






// MARK: - <#mark#>
protocol CustomDBType: Codable, CustomStringConvertible, CustomDebugStringConvertible {
    associatedtype CustomType: Codable
    
    var value: CustomType { set get }
    init(_ value: CustomType)
}

extension CustomDBType {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
    
    public var description: String {
        return "\(self.value)"
    }
    
    public var debugDescription: String {
        return description
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(CustomType.self))
    }
}
