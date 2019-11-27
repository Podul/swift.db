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

extension DB.Model {
    public init(id: Int) {
        self.init()
        self.id = DB.Primary(integerLiteral: id)
    }
}


public typealias DBCodable = Codable

/// 枚举需要遵守这个协议
public protocol DBEnum: DBCodable {
    static var valueType: Any.Type { get }
}

public protocol DBModel: DBCodable {
    var id: DB.Primary? { get set }
    init()
}
