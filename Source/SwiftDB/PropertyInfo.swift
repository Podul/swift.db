//
//  PropertyInfo.swift
//  swift.db
//
//  Created by Podul on 2019/11/15.
//  Copyright © 2019 Podul. All rights reserved.
//  属性信息

import Foundation

///
/// ```
/// public var SQLITE_INTEGER: Int32 { get }
/// public var SQLITE_FLOAT: Int32 { get }
/// public var SQLITE_BLOB: Int32 { get }
/// public var SQLITE_NULL: Int32 { get }
/// public var SQLITE_TEXT: Int32 { get }
/// public var SQLITE3_TEXT: Int32 { get }
/// ```
///

// MARK: - 属性信息
struct PropertyInfo {
    /// `Sqlite`类型与 `Swift` 类型映射
    enum DBType: String {
        /// 一个 NULL 值。
        case null = "NULL"
        /// 一个带符号的整数，根据值的大小存储在 1、2、3、4、6 或 8 字节中。
        /// 对应`Swift`中所有整型`（Int, UInt, Int8 ....）`
        case integer = "INTEGER"
        /// 一个文本字符串，使用数据库编码（UTF-8、UTF-16BE 或 UTF-16LE）存储。
        /// 对应`Swift`中字符串`String`
        case text = "TEXT"
        /// 一个浮点值，存储为 8 字节的 IEEE 浮点数字。
        /// 对应`Swift`中`Float Double`
        case real = "REAL"
        /// 对应`Swift`中`Data`
        /// 一个 blob 数据，完全根据它的输入存储。
        case blob = "BLOB"
        /// 其余暂不支持
    }
    
    // MARK: - Property
    /// 属性名
    var name: String
    /// 是否可为空
    var nullable: Bool = false
    /// 是否主键
    var isPrimary: Bool = false
    /// 类型
    var dbType: DBType = .text
    
    
    // MARK: - Fucntion
    static func info(with label: String, value: Any) -> PropertyInfo {
        
        var info = PropertyInfo(name: label)
        info.dbType = _readType(value)
        
        if value is _DBOptionalType {
            info.nullable = true
        }
        
        if value is _DBPrimaryType {
            // 主键不会为空
            info.isPrimary = true
            info.nullable = false
        }
        
        return info
    }
    
    /// 读取类型信息
    private static func _readType(_ value: Any) -> DBType {
        if value is _DBIntegerType {
            return .integer
        }else if value is _DBTextType {
            return .text
        }else if value is _DBRealType {
            return .real
        }else if value is _DBBlobType {
            return .blob
        }
        return .text
    }
}

extension DataBaseModel {
    var tableName: String {
        return "\(type(of: self))"
    }
    
    static var tableName: String {
        return "\(self.self)"
    }
    
    /// To Dictionary
    var db_dictValue: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            print(self)
            return [:]
        }
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
            print(self)
            return [:]
        }
        return dict
    }
    
    /// 字段信息
    var propertyInfos: [PropertyInfo] {
        let mirror = Mirror(reflecting: self)
        var field = [PropertyInfo]()
        for (label, value) in mirror.children {
            guard let label = label else { continue }
            field.append(PropertyInfo.info(with: label, value: value))
        }
        return field
    }
}


// MARK: - 方便判断类型
/// 如果还想支持哪些系统类型，可以在下面添加
/// `Optional`
private protocol _DBOptionalType {}
extension Optional: _DBOptionalType {}
extension Optional: _DBIntegerType where Wrapped: _DBIntegerType, Wrapped: _DBPrimaryType {}

/// `主键`
private protocol _DBPrimaryType {}
extension DB.Primary: _DBPrimaryType {}
extension Optional: _DBPrimaryType where Wrapped: _DBPrimaryType {}

/// 数据库`Integer`类型
private protocol _DBIntegerType {}
extension Int: _DBIntegerType {}
extension UInt: _DBIntegerType {}
extension DB.Integer: _DBIntegerType {}
extension DB.Primary: _DBIntegerType {}

/// 数据库`Text`类型
private protocol _DBTextType {}
extension String: _DBTextType {}
extension NSString: _DBTextType {}
extension DB.Text: _DBTextType {}
extension Optional: _DBTextType where Wrapped: _DBTextType {}


/// 数据库`Real`类型
private protocol _DBRealType {}
extension Double: _DBRealType {}
extension Float: _DBRealType {}
extension DB.Text: _DBRealType {}
extension Optional: _DBRealType where Wrapped: _DBRealType {}


/// 数据库`Blob`类型
private protocol _DBBlobType {}
extension Data: _DBBlobType {}
extension DB.Blob: _DBBlobType {}
// not support NSData
//extension NSData: _DBBlobType {}
extension Optional: _DBBlobType where Wrapped: _DBBlobType {}
