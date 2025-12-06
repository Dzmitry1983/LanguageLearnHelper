//
//  LHSQLWordsManager.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-12.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation



class LHSQLWordsManager : LHSQLBaseManager, LHSQLManagerProtocol {
	
	//MARK: - enums
	private let mainTableName = LHSQLWordModel.table
	enum CountType {
		case All
		case FirstLeters
	}
	
	//MARK:- constant properties
	private let createFields:[String:String] = [
		LHSQLWordModel.table:LHSQLWordModel.sqlCreateTable,
		LHSQLDefinitionModel.table:LHSQLDefinitionModel.sqlCreateTable,
		LHSQLTranslationModel.table:LHSQLTranslationModel.sqlCreateTable,
		]
	
	//MARK: - init's block
	override required init(_ databaseUrl:URL) {
		super.init(databaseUrl)
	}
	
	required override init(_ databasePath:String) {
		super.init(databasePath)
	}
	
	
	//MARK:- overrided public methods
	override func createFieldsCommands() -> [String:String] {
		return self.createFields
	}
	
	override func open(url:URL) {
		super.open(url: url)
		if let db = self.sqlDataBase {
			let commands = self.createFieldsCommands()
			for info in commands {
				self.createTable(info.key, keys:info.value, dataBase: db)
			}
		}
	}
	
	
	override func append<Type:SQLModelProtocol>(_ models:[Type], table:String) {
		if table == self.mainTableName {
			let blocksCount = 100
			let numbersForInsert = models.count / blocksCount
			print("numbersForInsert = \(numbersForInsert)")
			var id:Int32 = 1
			for number in 0...blocksCount {
				var forInsert = [LHSQLWordModel]()
				var forInsertDef = [LHSQLDefinitionModel]()
				var forInsertTranslations = [LHSQLTranslationModel]()
				
				let startIndex = numbersForInsert * number
				var endIndex = numbersForInsert * (number + 1) - 1
				
				if endIndex >= models.count {
					endIndex = models.count - 1
				}
				
				for i in startIndex...endIndex {
					if let model = models[i] as? LHSQLWordModel {
						model.id = id
						id += 1
						forInsert.append(model)
						
						for def in model.definitions {
							def.wordId = model.id
							forInsertDef.append(def)
						}
						
						for translation in model.translations {
							translation.wordId = model.id
							forInsertTranslations.append(translation)
						}
					}
				}
				super.append(forInsert, table:self.mainTableName)
				self.append(forInsertDef)
				self.append(forInsertTranslations)
				
				print("\(number)%")
			}
			print("count = \(models.count)")
		}
		else {
			super.append(models, table:table)
		}
	}
	
	//MARK: - get counts
	func count(countType:CountType, _ filter:String? = nil) -> Int {
		var returnValue:Int = 0
		if let db = self.sqlDataBase {
			returnValue = self.count(countType:countType, dataBase:db, filter:filter)
		}
		return returnValue
	}
	
	//MARK: - get models
	func firstLetters(_ filter:String? = nil) -> [(charater:String, count:Int)] {
		var returnValue = [(charater:String, count:Int)]()
		if let db = self.sqlDataBase {
			returnValue = self.firstLetters(dataBase: db, filter)
		}
		return returnValue
	}
	
	func wordsModel(number:Int, count:Int, _ filter:String = "") -> [LHSQLWordModel] {
		var returnValue = [LHSQLWordModel]()
		if let db = self.sqlDataBase {
			var start = number
			var cnt = count
			let date1 = Date()
			while cnt > 0 {
				let array = self.wordModels(number:start, count:cnt, dataBase:db, filter)
				if array.count > 0 && array.count < cnt {
					print(array.count)
					cnt -= array.count
					start += array.count
				}
				else {
					cnt = 0
				}
				returnValue.append(contentsOf: array)
			}
			let date2 = Date()
			print(date2.timeIntervalSince(date1))
			
		}
		return returnValue
	}
	
	func wordModelFull(model:LHSQLWordModel) {
		if let db = self.sqlDataBase {
			model.definitions = self.definitionModels(wordId: model.id, dataBase:db)
		}
	}
	
	//MARK: - read data
	private func count(countType:CountType, dataBase:OpaquePointer, filter:String?) -> Int {
		let tableName = self.mainTableName
		let collumnName = "\(tableName).word"
		var returnValue:Int = 0
		var statement: OpaquePointer? = nil
		var command:String
		switch countType {
		case .All:
			command = "select count(\(collumnName)) from \(tableName)"
		case .FirstLeters:
			command = "select count(distinct substr(\(collumnName), 1, 1)) from \(tableName)"
		}
		
		if filter != nil {
			command.append(" where word like ? ")
		}
		if sqlite3_prepare_v2(dataBase, command, -1, &statement, nil) != SQLITE_OK {
			self.printError(dataBase)
		}
		
		if filter != nil {
			let filterValue = filter! + "%"
            let bindTextResult = sqlite3_bind_text(statement, 1, filterValue, -1) { (pointer) in}
			if SQLITE_OK != bindTextResult {
				self.printError(dataBase)
			}
		}
		
		while sqlite3_step(statement) == SQLITE_ROW {
			let id = sqlite3_column_int(statement, 0)
			returnValue = Int(id)
		}
		
		if sqlite3_finalize(statement) != SQLITE_OK {
			self.printError(dataBase)
		}
		return returnValue
	}
	
	private func firstLetters(dataBase:OpaquePointer, _ filter:String? = nil) -> [(charater:String, count:Int)] {
		var returnValue = [(charater:String, count:Int)]()
		let tableName = self.mainTableName
		let collumnName = "\(tableName).word"
		var statement: OpaquePointer? = nil
//		select substr(Words.word, 1, 1) as character, count(word) as cnt from Words group by character ORDER BY cnt
		var command:String = "select substr(\(collumnName), 1, 1) as character, count(\(collumnName)) as cnt from \(tableName)"
		if filter != nil {
			command.append(" where word like ?")
		}
		command.append(" group by character")
		
		if sqlite3_prepare_v2(dataBase, command, -1, &statement, nil) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(dataBase))
			print("error preparing select: \(errmsg)")
		}
		
		if filter != nil {
			let filterValue = filter! + "%"
			if SQLITE_OK != sqlite3_bind_text(statement, 1, filterValue, -1) { (pointer) in} {
				self.printError(dataBase)
			}
		}
		
		while sqlite3_step(statement) == SQLITE_ROW {
			var value:(charater:String, count:Int)
			let charater = sqlite3_column_text(statement, 0)
			let count = sqlite3_column_int(statement, 1)
			value.charater = String.init(cString:charater!)
			value.count = Int(count)
			returnValue.append(value)
		}
		
		if sqlite3_finalize(statement) != SQLITE_OK {
			self.printError(dataBase)
		}
		return returnValue
	}
	
	private func wordModels(number:Int, count:Int, dataBase:OpaquePointer, _ filter:String = "") -> [LHSQLWordModel] {
		assert(number >= 0)
		assert(count > 0)
		var returnValue = [LHSQLWordModel]()
		let tableName = LHSQLWordModel.table
		var statement: OpaquePointer? = nil
		let command:String
		var numberOfValue:Int32 = 1
		let filterValue = "\(filter)%".cString(using: String.Encoding.utf8)
		if filter.isEmpty {
			command = "select * from \(tableName) limit ?, ?"
		}
		else {
			command = "select * from \(tableName) where word like ? limit ?, ?"
		}
		
		if sqlite3_prepare_v2(dataBase, command, -1, &statement, nil) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(dataBase))
			print("error preparing select: \(errmsg)")
		}
		
		if !filter.isEmpty {
			if SQLITE_OK != sqlite3_bind_text(statement, numberOfValue, filterValue, -1) { (pointer) in} {
				self.printError(dataBase)
			}
			numberOfValue += 1
		}
		let n = Int32(number)
		let c = Int32(count)
		if SQLITE_OK != sqlite3_bind_int(statement, numberOfValue, n) {
			self.printError(dataBase)
		}
		numberOfValue += 1
		if SQLITE_OK != sqlite3_bind_int(statement, numberOfValue, c) {
			self.printError(dataBase)
		}
		numberOfValue += 1
		
		var ll = sqlite3_step(statement)
		while ll == SQLITE_ROW {
			let id = sqlite3_column_int(statement, 0)
			let word = sqlite3_column_text(statement, 1)
			let transcription = sqlite3_column_text(statement, 2)
			let speach = sqlite3_column_int(statement, 3)
			let model = LHSQLWordModel()
			model.id = id
			model.word = String.init(cString:word!)
			if transcription != nil {
				model.transcription = String.init(cString:transcription!)
			}
			model.speech = model.speechTypeFromInt(speach)
			returnValue.append(model)
			ll = sqlite3_step(statement)
		}
		if sqlite3_finalize(statement) != SQLITE_OK {
			self.printError(dataBase)
		}
		return returnValue
	}
	
	
	
	private func definitionModels(wordId:Int32, dataBase:OpaquePointer) -> [LHSQLDefinitionModel] {
		var returnValue = [LHSQLDefinitionModel]()
		let tableName = LHSQLDefinitionModel.table
		var statement: OpaquePointer? = nil
		let command:String = "select * from \(tableName) where wordId = ?"
		//select * from Definitions where Definitions.wordId = 5
		
		if sqlite3_prepare_v2(dataBase, command, -1, &statement, nil) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(dataBase))
			print("error preparing select: \(errmsg)")
		}
		
		if SQLITE_OK != sqlite3_bind_int(statement, 1, wordId) {
			self.printError(dataBase)
		}
		
		while sqlite3_step(statement) == SQLITE_ROW {
			let id = sqlite3_column_int(statement, 0)
			let wordId = sqlite3_column_int(statement, 1)
			let word = sqlite3_column_text(statement, 2)
			let model = LHSQLDefinitionModel()
			model.id = id
			model.definition = String.init(cString:word!)
			model.wordId = wordId
			returnValue.append(model)
		}
		if sqlite3_finalize(statement) != SQLITE_OK {
			self.printError(dataBase)
		}
		return returnValue
	}
	
	

}
