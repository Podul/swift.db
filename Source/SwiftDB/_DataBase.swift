//
//  _DataBase.swift
//  Pods-swift.db_Example
//
//  Created by Podul on 2019/11/25.
//

import Foundation
import SQLite3

typealias Callback = (@convention(c) (UnsafeMutableRawPointer?, Int32, UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?, UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32)

/// 需要自己维护实例对象
final internal class _DataBase {
    
    private var _db: OpaquePointer?
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
        let isOk = sqlite3_close(_db)
        sqlite3_db_release_memory(_db)
        _db = nil
        return isOk == SQLITE_OK
    }
    
    // MARK: - SQL
    /// 执行 sql（建表、增、删、改都是这个方法）
    @discardableResult
    func exec(_ sql: String) -> Bool {
        let cSql = sql.cString(using: .utf8)
        
        return sqlite3_exec(_db, cSql, { _, _, _, _ -> Int32 in
            // TODO: 
            return 0
        }, nil, nil) == SQLITE_OK
    }
    
    /// 查
    @discardableResult
    func query(_ sql: String) -> [[String: Codable]] {
        var pStmt: OpaquePointer?
        let cSql = sql.cString(using: .utf8)
        var arr = [[String: Codable]]()
        
        let status = sqlite3_prepare_v2(_db, cSql, -1, &pStmt, nil)
        defer {
            sqlite3_finalize(pStmt)
        }
        if status != SQLITE_OK {
            print("没有准备好")
            return arr
        }
        
        while sqlite3_step(pStmt) == SQLITE_ROW {
            
            var dict = [String: Codable]()
            var i: Int32 = 0
            // 字段名
            while let cName = sqlite3_column_name(pStmt, i) {
                defer { i = i + 1 }
                let fieldName = String(cString: cName)
                // 字段类型
                let type = sqlite3_column_type(pStmt, i)
                switch type {
                case SQLITE3_TEXT:
                    guard let cString = sqlite3_column_text(pStmt, i) else { continue }
                    dict[fieldName] = String(cString: cString)
                case SQLITE_INTEGER:
                    let int64Value = sqlite3_column_int64(pStmt, i)
                    dict[fieldName] = Int(int64Value)
                case SQLITE_FLOAT:
                    let doubleValue = sqlite3_column_double(pStmt, i)
                    dict[fieldName] = doubleValue
                case SQLITE_BLOB:
                    guard let blobValue = sqlite3_column_blob(pStmt, i) else { continue }
                    dict[fieldName] = Data(bytes: blobValue, count: Int(sqlite3_column_bytes(pStmt, i)))
                default: break
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
        
        if _db != nil {
            sqlite3_close(_db)
            sqlite3_db_release_memory(_db)
            _db = nil
        }
        print("database saved in \(dbPath)")
        let cDBPath = dbPath.cString(using: .utf8)
        
        let state = sqlite3_open(cDBPath, &_db)
        if state != SQLITE_OK {
            print("打开失败")
        }
    }
}
