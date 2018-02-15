//
//  LHSQLBaseManager.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-17.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation



/*
Class for work sql database
commands:
internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
SELECT DISTINCT substr(word, 1, 1) from Words
"select count(*) from \(tableName) where word like ? "
select substr(Words.word, 1, 1) as character, count(word) as dist from Words group by character ORDER BY dist
select Words.word, Definitions.definition from Words inner join Definitions on Words.id = Definitions.wordId limit 0, 100000
pragma table_info(Words);
.schema tablename
SELECT name FROM  (SELECT * FROM sqlite_master UNION ALL  SELECT * FROM sqlite_temp_master) WHERE type='table' ORDER BY name
SELECT name FROM  sqlite_temp_master
SELECT name FROM  contact.sqlite_master

SELECT name FROM  (SELECT * FROM sqlite_master UNION ALL  SELECT * FROM sqlite_temp_master) WHERE type='table' ORDER BY name
ATTACH DATABASE file_name AS database_name;
DETACH DATABASE 'Alias-Name';
UPDATE `Studying` SET `word`=? WHERE `_rowid_`='1';
UPDATE `Studying` SET `word`=? WHERE `_rowid_`='1';
UPDATE `Studying` SET studyGroup='Common 3000';

UPDATE `Studying` SET `wordId`=(SELECT Words.id FROM `Words` WHERE Words.word = Studying.word and Words.speech = Studying.speech)

examples from
http://stackoverflow.com/questions/24102775/accessing-an-sqlite-database-in-swift
*/

//types INTEGER, REAL, TEXT, BLOB


class LHSQLBaseManager {
	//MARK:- private properties
	private let beginSqlTransaction = "begin transaction"
	private let commitSqlTransaction = "commit transaction"
	private let insertSqlCommand = "insert into "
	private let supportedDatabases = ["sqlite_sequence", "sqlite_master", "sqlite_temp_master"]
	private var databases = [String]()
	
	//MARK:- properties
	var sqlDataBase: OpaquePointer!
	
	init(_ databaseUrl:URL) {
		self.open(url: databaseUrl)
	}
	
	init(_ databasePath:String) {
		if let url = URL.init(string:databasePath) {
			self.open(url: url)
		}
		else {
			assert(false)
		}
	}
	
	
	
	
	func createFieldsCommands() -> [String:String] {
		assert(false, "need to be overrided")
		return [String:String]()
	}
	
	func append<Type:SQLModelProtocol>(_ models:[Type]) {
		self.append(models, table:Type.table)
	}
	
	//MARK:- init/deinit
	deinit {
		self.close()
	}
	
	
	//Create/open database.
	func open(url:URL) {
		self.close()
		self.sqlDataBase = self.openDataBase(url: url)
	}
	
	func openDataBase(url:URL) -> OpaquePointer? {
		var dataBase: OpaquePointer? = nil
		if sqlite3_open(url.path, &dataBase) != SQLITE_OK {
			print("error opening database")
			assert(false)
		}
		return dataBase
	}
	
	func clearAllTables() {
		if let db = self.sqlDataBase {
			let commands = self.createFieldsCommands()
			for info in commands {
				self.dropTable(info.key, dataBase: db)
				self.createTable(info.key, keys:info.value, dataBase: db)
			}
		}
	}
	
	func attachDatabase(_ databasePath:String, databaseName:String) {
		
		if FileManager.default.fileExists(atPath: databasePath) {
			let command = "ATTACH DATABASE `\(databasePath)` AS `\(databaseName)`;"
			if sqlite3_exec(self.sqlDataBase, command, nil, nil, nil) != SQLITE_OK {
				self.printError(self.sqlDataBase)
			}
			else {
				self.databases.append(databaseName)
			}
		}
		else {
			assert(false, "file \(databasePath) didn't find")
		}
	}
	
	func attachDatabase(_ databaseUrl:URL, databaseName:String) {
		let absolutlePath = databaseUrl.path
//		let rlvt = databaseUrl.relativePath
		self.attachDatabase(absolutlePath, databaseName: databaseName)
	}
	
	func detachDatabase(_ databaseName:String) {
		if let index = self.databases.index(of:databaseName) {
			let command = "DETACH DATABASE `\(databaseName)`;"
			if sqlite3_exec(self.sqlDataBase, command, nil, nil, nil) != SQLITE_OK {
				self.printError(self.sqlDataBase)
			}
			else {
				self.databases.remove(at: index)
			}
		}
	}
	
	
	//Use sqlite3_exec to drop table SQL (e.g. create table).
	func dropTable(_ table:String, dataBase:OpaquePointer) {
		let command = "DROP TABLE IF EXISTS '\(table)';"
		if sqlite3_exec(dataBase, command, nil, nil, nil) != SQLITE_OK {
			self.printError(dataBase)
		}
	}
	
	//Use sqlite3_exec to perform SQL (e.g. create table).
	func createTable(_ tableName:String, keys:String, dataBase:OpaquePointer) {
		let command = "CREATE TABLE IF NOT EXISTS '\(tableName)' (\(keys));"
		if sqlite3_exec(dataBase, command, nil, nil, nil) != SQLITE_OK {
			self.printError(dataBase)
		}
	}
	
	//close the database
	func close() {
		if let dataBase = self.sqlDataBase {
			if sqlite3_close(dataBase) != SQLITE_OK {
				print("error closing database")
				assert(false)
			}
			self.sqlDataBase = nil
		}
	}
	
	//Work with errors
	func printError(_ dataBase:OpaquePointer) {
		let errmsg = String(cString: sqlite3_errmsg(dataBase))
		print("error finalizing prepared statement: \(errmsg)")
		assert(false)
	}
	
	//Work with database info
	func tables() -> [LHSQLTableInfoProtocol] {
		var returnValue:[LHSQLTableInfoProtocol] = self.tablesFromDatabase()
		for databaseName in self.databases {
			let array = self.tablesFromDatabase(databaseName)
			returnValue.append(contentsOf:array)
		}
		return returnValue
	}
	
	
	
	private func tablesFromDatabase(_ databaseName:String? = nil) -> [LHSQLTableInfoProtocol] {
		var returnValue = [LHSQLInfoTable]()
		let database = databaseName != nil ? "\(databaseName!)." : ""
		let command = "SELECT name FROM \(database)SQLITE_MASTER;"
		var statement: OpaquePointer? = nil
		
		if sqlite3_prepare_v2(self.sqlDataBase, command, -1, &statement, nil) != SQLITE_OK {
			self.printError(self.sqlDataBase)
		}
		
		while sqlite3_step(statement) == SQLITE_ROW {
			let tableName = sqlite3_column_text(statement, 0)
			let string = String.init(cString:tableName!)
			if !self.supportedDatabases.contains(string) {
				let tableInfo = LHSQLInfoTable(string)
				tableInfo.database = databaseName
				returnValue.append(tableInfo)
			}
		}
		if sqlite3_finalize(statement) != SQLITE_OK {
			self.printError(self.sqlDataBase)
		}
		return returnValue
	}
	
	func count(_ table:String) -> Int64 {
		var returnValue:Int64 = 0
		let command = "SELECT count(*) FROM \(table);"
		var statement: OpaquePointer? = nil
		
		if sqlite3_prepare_v2(self.sqlDataBase, command, -1, &statement, nil) != SQLITE_OK {
			self.printError(self.sqlDataBase)
		}
		
		if sqlite3_step(statement) == SQLITE_ROW {
			returnValue = sqlite3_column_int64(statement, 0)
		}
		if sqlite3_finalize(statement) != SQLITE_OK {
			self.printError(self.sqlDataBase)
		}
		return returnValue
	}
	
	//MARK: - insert datas
	func append<Type:SQLModelProtocol>(_ models:[Type], table:String) {
		if let dataBase = self.sqlDataBase {
			var fields = [String]()
			let values = [String].init(repeating:"?", count:Type.sqlFields.count)
			var fieldsNumbers = [Int32:String]()
			var lastNumber:Int32 = 1
			for field in Type.sqlFields {
				fields.append("`\(field)`")
				fieldsNumbers[lastNumber] = field
				lastNumber += 1
			}
			let fieldsCommand = fields.joined(separator: ", ")
			let valuesCommand = values.joined(separator: ", ")
			let command = insertSqlCommand + "\(table) (\(fieldsCommand)) VALUES(\(valuesCommand)) "
			var statement: OpaquePointer? = nil
			var testArra = [[CChar]?]()
			if sqlite3_exec(dataBase, self.beginSqlTransaction, nil, nil, nil) != SQLITE_OK {
				self.printError(dataBase)
			}
			
			if sqlite3_prepare_v2(dataBase, command, -1, &statement, nil) != SQLITE_OK {
				self.printError(dataBase)
			}
			
			for model in models {
				for key in fieldsNumbers.keys.sorted() {
					let keyValue = fieldsNumbers[key]!
					let fieldValue = model[keyValue]
					let number = key
					switch fieldValue {
					case let value as String:
						let buff = value.cString(using: String.Encoding.utf8)
						//hack for keep data until it will be saved
						testArra.append(buff)
						if sqlite3_bind_text(statement, number, buff, -1, nil) != SQLITE_OK {
							self.printError(dataBase)
						}
					case let value as Int32:
						if SQLITE_OK != sqlite3_bind_int(statement, number, value) {
							self.printError(dataBase)
						}
					case _ as NSNull:
						if SQLITE_OK != sqlite3_bind_null(statement, number) {
							self.printError(dataBase)
						}
					default:
						assert(false)
					}
				}
				
				
				
				if sqlite3_step(statement) != SQLITE_DONE {
					self.printError(dataBase)
				}
				var editableModel = model
				
				editableModel.id = Int32(sqlite3_last_insert_rowid(dataBase))
				if sqlite3_reset(statement) != SQLITE_OK {
					self.printError(dataBase)
				}
				
			}
			
			if sqlite3_exec(dataBase, self.commitSqlTransaction , nil, nil, nil) != SQLITE_OK {
				self.printError(dataBase)
			}
			
			if sqlite3_finalize(statement) != SQLITE_OK {
				self.printError(dataBase)
			}
			
		}
	}
	
	//MARK: - updates 
//	func update<Table:LHSQLTableProtocol>(_ table:Table) {
//		let tableName = table.tableInfo.name
//		let command = "UPDATE `\(tableName)` SET studyGroup='Common 3000';"
//		
//	}
}
