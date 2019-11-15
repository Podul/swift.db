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
public enum DB {
    public struct Manager {
        
        private static var db: DataBase?
        
        /// 打开指定数据库，如果数据库不存在则创建
        public static func open(db name: String? = nil, create tables: DataBaseModel.Type...) {
            db?.closeDB()
            if let name = name {
                db = DataBase(name)
            }else {
                db = DataBase.default
            }
            db?.create(tables)
        }
        
        /// 插入（增）
        @discardableResult
        public static func insert(_ model: DataBaseModel) -> Bool {
            var keys = ""
            var values = ""
            for (key, value) in model.db_dictValue {
                let infos = model.fieldInfos.filter { $0.name == key && $0.isPrimary }
                if infos.count > 0 { continue }
                
                keys.append(key + " ,")
                values.append("'\(value)' ,")
            }
            keys.removeLast()
            values.removeLast()
            
            let insertSql = "INSERT INTO \(model.tableName) (\(keys)) VALUES (\(values));"
            guard let db = db else {
                fatalError("db does not opened")
            }
            if !db.exec(insertSql) {
                print(insertSql)
                return false
            }
            return true
        }
        
        /// 删除（删）
        @discardableResult
        public static func delete(_ model: DataBaseModel) -> Bool {
            let deleteSql = "DELETE FROM \(model.tableName) WHERE id = \(model.id);"
            guard let db = db else {
                fatalError("db does not opened")
            }
            if !db.exec(deleteSql) {
                print(deleteSql)
                return false
            }
            return true
        }
        
        /// 修改（改）
        @discardableResult
        public static func update(_ model: DataBaseModel) -> Bool {
            var sql = ""
            for (key, value) in model.db_dictValue {
                let s = "\(key) = '\(value)',"
                sql.append(s)
            }
            sql.removeLast()
            
            let updateSql = "UPDATE \(model.tableName) SET \(sql) WHERE id = \(model.id);"
            guard let db = db else {
                fatalError("db does not opened")
            }
            if !db.exec(updateSql) {
                print(updateSql)
                return false
            }
            return true
        }

        /// 查询
        @discardableResult
        public static func query<T>(_ model: T.Type, where sql: String = "") -> [T] where T: DataBaseModel {
            let querySql = "SELECT * FROM \(model.tableName) WHERE \(sql);"
            guard let db = db else {
                fatalError("db does not opened")
            }
            let queryResult = db.query(querySql)
            
            do {
                let data = try JSONSerialization.data(withJSONObject: queryResult, options: .prettyPrinted)
                return try JSONDecoder().decode([T].self, from: data)
            } catch {
                print(queryResult)
                print(error)
                return [T]()
            }
        }
        
        /// 查询
        /// 如果需要更复杂的功能，请使用该方法
        @discardableResult
        public static func query(_ sql: String) -> [Any] {
            guard let db = db else {
                fatalError("db does not opened")
            }
            return db.query(sql)
        }
        
        /// 除查询外所有方法
        /// 如果需要更复杂的功能，请使用该方法
        @discardableResult
        public static func exec(_ sql: String) -> Bool {
            guard let db = db else {
                fatalError("db does not opened")
            }
            return db.exec(sql)
        }
        
        /// 关闭数据库
        public static func close() -> Bool {
            guard let db = db else {
                fatalError("db does not opened")
            }
            return db.closeDB()
        }
    }
}
