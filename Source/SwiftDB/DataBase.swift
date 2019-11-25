//
//  DataBase.swift
//  swift.db
//
//  Created by Podul on 2019/11/15.
//  Copyright © 2019 Podul. All rights reserved.
//  数据库

import Foundation
import SQLite3


/// # 删除表
/// `DROP TABLE IF EXISTS t_student;`
///
/// # 创建表
/// ```
/// CREATE TABLE IF NOT EXISTS 't_student' (
/// "id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,/* 主键   自动增长 */
/// "name" text UNIQUE,
/// "class" integer, CONSTRAINT "f_student_rel_class" FOREIGN KEY ("class") REFERENCES "t_class" ("id"));
/// "age' integer );
/// ```
/// 用约束 `f_student_rel_class` 的 `class`外键 引用 `t_class`表的 主键 id字段
/// `NOT NULL` 约束的字段不能为空 `PRIMARY KEY` 约束的字段是主键 `AUTOINCREMENT` 主键自增长 `UNIQUE` 约束的字段 是唯一的，即在数据库中不能重复 `DEFAULT` 默认值
///
///  # 插入数据
/// `INSERT INTO t_student (name,age) VALUES ('张飞',11);`
///
///  # 更新数据
/// `UPDATE t_student SET age = 45 WHERE name = '林冲';`
///
/// # 删除数据
/// 1. 根据用户名删除数据
/// `DELETE FROM t_student WHERE name = '西门庆';`
/// 2. 删除表中所有值
/// `DELETE FROM t_student; `
///
/// # 查询语句
/// 根据名字首字是张的条件查询  % 代表后面剩余的是任意字符
/// `SELECT name,age FROM t_student WHERE name LIKE '张%';`
///
/// # 计算个数
/// 1. 数据总条数
/// `SELECT COUNT(*) FROM t_student;`
/// 2. age不为空的个数
/// `SELECT COUNT(age) FROM t_student;`
///
/// # 排序
/// 1. 通过年龄排序 默认升序，`DESC`降序、`ASC`升序
/// `SELECT * FROM t_student ORDER BY age ASC;`
/// 2. 先以年龄的升序排序，如果年龄相同，以名字的降序排序
/// `SELECT * FROM t_student ORDER BY age, name DESC;`
///
/// # 别名
/// 1. 给表起别名
/// `SELECT s.name,s.age FROM t_student AS s;`
/// 2. 给字段起别名
/// `SELECT name AS myName,age AS myAge FROM t_student;`
///
/// # 分页
/// 1. 1表示跳过的数据个数，2表示查询多少条
/// `SELECT name,age FROM t_student LIMIT 1,2;`
///



public protocol DataBaseModel: Codable {
    var id: Primary { get }
    init()
}

extension DataBaseModel {
    var tableName: String {
        return "\(type(of: self))"
    }
    static var tableName: String {
        return "\(self.self)"
    }
    
    /// 字段信息
    var fieldInfos: [PropertyInfo] {
        let mirror = Mirror(reflecting: self)
        var field = [PropertyInfo]()
        for (label, value) in mirror.children {
            guard let label = label else { continue }
            field.append(PropertyInfo.info(with: label, value: value))
        }
        return field
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
}


// MARK: - 数据库
final class DataBase {
    
    private let _db: _DataBase
    /// 所有表名
    private lazy var tableInfos = [String: [PropertyInfo]]()
    
    init(_ dbPath: String, tables: [DataBaseModel.Type]) {
        // 打开数据库
        _db = _DataBase(dbPath)
        // 创建表
        _create(tables)
    }
    
    deinit {
        print("database deinit")
    }
    
    // MARK: - Private
    /// 新建表
    func _create(_ tables: [DataBaseModel.Type]) {
        // 保存表的信息
        _savedTableInfos(by: tables)
        
        // 创建表
        _createTables()
    }
    
    /// 保存表的信息
    private func _savedTableInfos(by tables: [DataBaseModel.Type]) {
        for table in tables {
            let t = table.init()
            tableInfos[t.tableName] = t.fieldInfos
        }
    }
    
    /// 创建表
    private func _createTables() {
        for (tableName, infos) in tableInfos {
            var sql = ""
            for info in infos {
                // 主键不为空
                let notNull = (info.nullable && !info.isPrimary) ? "NULL" : "NOT NULL"
                let primary = info.isPrimary ? "PRIMARY KEY AUTOINCREMENT" : ""
                // it likes "tableName TEXT NOT NULL PRIMARY KEY AUTOINCREMENT,"
                let s = "\(info.name) \(info.dbType.rawValue) \(notNull) \(primary),"
                sql.append(s)
            }
            sql.removeLast()
            
            let createSql =
            """
                CREATE TABLE IF NOT EXISTS \(tableName) (
                    \(sql)
                )
            """
            
            if !exec(createSql) {
                print(createSql)
                print("创建失败")
            }
        }
    }
    
    // MARK: - 数据库操作
    /// 插入（增）
    @discardableResult
    func insert(_ model: DataBaseModel) -> Bool {
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
        if !_db.exec(insertSql) {
            print(insertSql)
            return false
        }
        return true
    }
    
    /// 删除（删）
    @discardableResult
    func delete(_ model: DataBaseModel) -> Bool {
        let deleteSql = "DELETE FROM \(model.tableName) WHERE id = \(model.id);"
        if !_db.exec(deleteSql) {
            print(deleteSql)
            return false
        }
        return true
    }
    
    /// 修改（改）
    @discardableResult
    func update(_ model: DataBaseModel) -> Bool {
        var sql = ""
        for (key, value) in model.db_dictValue {
            let s = "\(key) = '\(value)',"
            sql.append(s)
        }
        sql.removeLast()
        
        let updateSql = "UPDATE \(model.tableName) SET \(sql) WHERE id = \(model.id);"
        if !_db.exec(updateSql) {
            print(updateSql)
            return false
        }
        return true
    }

    /// 查询
    @discardableResult
    func query<T>(_ model: T.Type, where sql: String) -> [T] where T: DataBaseModel {
        let whereSql = sql.isEmpty ? "" : "WHERE \(sql)"
        let querySql = "SELECT * FROM \(model.tableName) \(whereSql);"
        let queryResult = _db.query(querySql)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: queryResult, options: .prettyPrinted)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print(queryResult)
            print(error)
            return [T]()
        }
    }
    
    // MARK: - Other
    /// 关闭数据库
    @discardableResult
    func closeDB() -> Bool {
        return _db.closeDB()
    }
    
    // MARK: - SQL 语句
    /// 执行 sql（建表、增、删、改都是这个方法）
    @discardableResult
    func exec(_ sql: String) -> Bool {
        return _db.exec(sql)
    }
    
    /// 查
    @discardableResult
    func query(_ sql: String) -> [[String: Codable]] {
        return _db.query(sql)
    }
}




