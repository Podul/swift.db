//
//  _DataBase.swift
//  Pods-swift.db_Example
//
//  Created by Podul on 2019/11/25.
//

import Foundation
import SQLite3


/// 需要自己维护实例对象
final internal class _DataBase {
    
    private var db: OpaquePointer?
    /// 数据库名字
    private let dbPath: String
    
    init(_ dbPath: String) {
        self.dbPath = dbPath
        _openDB()
    }
    
    deinit {
        print("database deinit")
        closeDB()
    }
    
    // MARK: - Public
    /// 关闭数据库
    @discardableResult
    func closeDB() -> Bool {
        let isOk = sqlite3_close(db)
        sqlite3_db_release_memory(db)
        db = nil
        return isOk == SQLITE_OK
    }
    
    // MARK: - SQL
    /// 执行 sql（建表、增、删、改都是这个方法）
    @discardableResult
    func exec(_ sql: String) -> Bool {
        let cSql = sql.cString(using: .utf8)
        return sqlite3_exec(db, cSql, nil, nil, nil) == SQLITE_OK
    }
    
    /// 查
    @discardableResult
    func query(_ sql: String) -> [[String: Codable]] {
        var queryPoint: OpaquePointer?
        let cSql = sql.cString(using: .utf8)
        var arr = [[String: Codable]]()
        
        if sqlite3_prepare(db, cSql, -1, &queryPoint, nil) != SQLITE_OK {
            print("没有准备好")
            return arr
        }
        
        while sqlite3_step(queryPoint) == SQLITE_ROW {
            var dict = [String: Codable]()
            var i: Int32 = 0
            // 字段名
            while let cName = sqlite3_column_name(queryPoint, i) {
                defer {
                    i = i + 1
                }
                let fieldName = String(cString: cName)
                // 字段类型
                let type = sqlite3_column_type(queryPoint, i)
                switch type {
                case SQLITE3_TEXT:
                    let textValue = sqlite3_column_text(queryPoint, i)
                    guard let cString = textValue else { continue }
                    dict[fieldName] = String(cString: cString)
                case SQLITE_INTEGER:
                    let int64Value = sqlite3_column_int64(queryPoint, i)
                    dict[fieldName] = Int(int64Value)
                case SQLITE_FLOAT:
                    let doubleValue = sqlite3_column_double(queryPoint, i)
                    dict[fieldName] = doubleValue
                case SQLITE_BLOB:
                    let blobValue = sqlite3_column_blob(queryPoint, i)
                    guard let blobValue1 = blobValue else { continue }
                    dict[fieldName] = Data(bytes: blobValue1, count: Int(sqlite3_column_bytes(queryPoint, i)))
                default:
                    break
                }
            }
            arr.append(dict)
        }
        return arr
    }
    
    
    // MARK: - Private
    /// 打开数据库
    private func _openDB() {
        
        if dbPath.isEmpty {
            fatalError("dbPath is nil");
        }
        
        if db != nil {
            sqlite3_close(db)
            sqlite3_db_release_memory(db)
            db = nil
        }
        print("database saved in \(dbPath)")
        let cDBPath = dbPath.cString(using: .utf8)
        
        let state = sqlite3_open(cDBPath, &db)
        if state != SQLITE_OK {
            print("打开失败")
        }
    }
}
