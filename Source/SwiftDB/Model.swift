//
//  Model.swift
//  Pods-smb
//
//  Created by Podul on 2019/11/27.
//

import Foundation


extension DB {
    public typealias Enum = DBEnum
    public typealias Model = DBModel
}



public typealias DBCodable = Codable

/// 枚举需要遵守这个协议
public protocol DBEnum: DBCodable {
    static var valueType: Any.Type { get }
}


public protocol DBModel: DBCodable {
//    associatedtype IDKey
    // 主键
    var id: Int? { get set }
}
