//
//  Manager.swift
//  swift.db
//
//  Created by Podul on 2019/11/15.
//  Copyright © 2019 Podul. All rights reserved.
//  对外公开的数据库管理方式

import Foundation

///
/// # 使用方法：
/// 1. 首先，你需要创建遵守`DataBaseModel`协议的模型，你可以使用一些基础类型，e.g. `Int` `String` `Float`等，也可以使用`Text` `Integer`等数据库支持的类型。
/// 2. 然后调用 `DB.Manager.open(db name:, andCreate:)`方法创建并打开数据库
/// 3. 最后就可以调用`DB.Manager.insert`等方法进行数据库操作了
///
/// ```
/// struct Model: DataBaseModel {
///     var id: Primary = 0
///     var name: String = "name"
///     var text: Text = "text"
///     ...
/// }
///
/// DB.Manager.open(db: "dbname.sqlite3", create: Model.self)
///
/// struct Model: DataBaseModel {
///     var id: Primary = 0
///     var name: String = "name"
///     var text: Text = "text"
///     var optional: String? = nil
/// }
///
/// model.id = ...
/// model.text = "text222"
/// // 修改数据需要知道 id
/// DB.Manager.update(model)
///
/// ...
/// ...
/// ```
///

extension DB {

    public struct Manager {
        
        private static var _db: DataBase!
        
        /// 打开指定数据库，如果数据库不存在则创建
        public static func open(db path: String? = nil, tables: DataBaseModel.Type...) {
            _db?.closeDB()
            
            if let path = path {
                _db = DataBase(path, tables: tables)
            }else {
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? ""
                _db = DataBase(path + "/defalut.sqlite3", tables: tables)
            }
        }
        
        /// 插入（增）
        @discardableResult
        public static func insert(_ model: DataBaseModel) -> Bool {
            return _db.insert(model)
        }
        
        /// 删除（删）
        @discardableResult
        public static func delete(_ model: DataBaseModel) -> Bool {
            return _db.delete(model)
        }
        
        /// 修改（改）
        @discardableResult
        public static func update(_ model: DataBaseModel) -> Bool {
            return _db.update(model)
        }
        
        /// 查询（查）
        @discardableResult
        public static func query<T>(_ model: T.Type, where sql: String = "") -> [T] where T: DataBaseModel {
            return _db.query(model, where: sql)
        }
        
        /// 查询
        /// 如果需要更复杂的功能，请使用该方法
        @discardableResult
        public static func query(_ sql: String) -> [Any] {
            return _db.query(sql)
        }
        
        /// 除查询外所有方法
        /// 如果需要更复杂的功能，请使用该方法
        @discardableResult
        public static func exec(_ sql: String) -> Bool {
            return _db.exec(sql)
        }
        
        /// 关闭数据库
        public static func close() -> Bool {
            return _db.closeDB()
        }
    }

}


/// 数据库操作
extension DataBaseModel {
    @discardableResult
    public func insert() -> Bool {
        return DB.Manager.insert(self)
    }
    
    @discardableResult
    public func update() -> Bool {
        return DB.Manager.update(self)
    }
    
    @discardableResult
    public func delete() -> Bool {
        return DB.Manager.delete(self)
    }
    
    @discardableResult
    static public func query(where sql: String = "") -> [Self] {
        return DB.Manager.query(self, where: sql)
    }
}
