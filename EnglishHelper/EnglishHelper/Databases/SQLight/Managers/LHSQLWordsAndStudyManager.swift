//
//  LHSQLWordsAndStudyManager.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-19.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

protocol LHSQLWordsAndStudyProtocol : LHSQLManagerProtocol {
//	init(mainDB:String, attachedDB:String)
	func firstLetters(studyType:LHSQLStudyingModel.Progress, _ filter:String) -> [(charater:String, count:Int)]
	func wordModelFull(model:LHSQLWordModel)
	func wordsModel(number:Int, count:Int, studyType:LHSQLStudyingModel.Progress, _ filter:String) -> LHSQLTableWordsAndStudy
	func wordsRandomModel(count:Int, studyType:LHSQLStudyingModel.Progress, _ filter:String) -> LHSQLTableWordsAndStudy
	
	func save(_ model:LHSQLStudyingModel)
	func update<Type:SQLModelProtocol>(_ model:Type)
}

class LHSQLFilter : CustomStringConvertible {
	var fieldName:String
	var value:Any
	var comparison:String
	var number:Int32 = 0
	
	var description: String {
		return "\(fieldName) \(comparison) ?"
	}
	
	init(_ fieldName:String, _ comparison:String, _ value:Any) {
		self.fieldName = fieldName
		self.value = value
		self.comparison = comparison
	}
}

class LHSQLWordsAndStudyManager: LHSQLBaseManager, LHSQLManagerProtocol, LHSQLWordsAndStudyProtocol {
	//MARK: - enums
	private let mainTableName = LHSQLWordModel.table
	
	//MARK: - override's block
	override required init(_ databaseUrl:URL) {
		super.init(databaseUrl)
	}
	
	required override init(_ databasePath:String) {
		super.init(databasePath)
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
	
	//MARK: - 
	
	func updateStudyTable() {
//		UPDATE `Studying` SET `wordId`=(SELECT Words.id FROM `Words` WHERE Words.word = Studying.word and Words.speech = Studying.speech)
	}
	
	//MARK: - get models
	func firstLetters(studyType:LHSQLStudyingModel.Progress, _ filter:String = "") -> [(charater:String, count:Int)] {
		var returnValue = [(charater:String, count:Int)]()
		if let dataBase = self.sqlDataBase {
			var statement: OpaquePointer? = nil
			
			let wordsTable = "Words"
			let studyTable = "Studying"
			let collumnName = "\(wordsTable).word"
			let selectComand = "select substr(\(collumnName), 1, 1) as character, count(\(collumnName)) as cnt"
			let equalization = "\(wordsTable).word = \(studyTable).word and \(wordsTable).speech = \(studyTable).speech"
			var command = "\(selectComand) from \(wordsTable) LEFT OUTER JOIN \(studyTable) on \(equalization)"
			
			
			var cacheArray = [[CChar]?]()
			//make where
			var whereArray = [LHSQLFilter]()
			if studyType != .all {
				let filterModel = LHSQLFilter("Studying.studyType", "=", studyType.rawValue)
				whereArray.append(filterModel)
			}
			
			if !filter.isEmpty {
				let filterValue = filter + "%"
				let filterModel = LHSQLFilter("Words.word", "like", filterValue)
				whereArray.append(filterModel)
			}
			
			if whereArray.count > 0 {
				command.append(" where ")
			}
			var number:Int32 = 1
			for filterModel in whereArray {
				filterModel.number = number
				number += 1
				if filterModel.number > 1 {
					command.append(" and ")
				}
				command.append(filterModel.description)
			}
			
			command.append(" group by character")
			
			if sqlite3_prepare_v2(dataBase, command, -1, &statement, nil) != SQLITE_OK {
				let errmsg = String(cString: sqlite3_errmsg(dataBase))
				print("error preparing select: \(errmsg)")
			}
			
			for filterModel in whereArray {
				switch filterModel.value {
				case let value as String:
					let buff = value.cString(using: String.Encoding.utf8)
					//hack for keep data until it will be saved
					cacheArray.append(buff)
					if sqlite3_bind_text(statement, filterModel.number, buff, -1, nil) != SQLITE_OK {
						self.printError(dataBase)
					}
				case let value as Int32:
					if SQLITE_OK != sqlite3_bind_int(statement, filterModel.number, value) {
						self.printError(dataBase)
					}
				case _ as NSNull:
					if SQLITE_OK != sqlite3_bind_null(statement, filterModel.number) {
						self.printError(dataBase)
					}
				default:
					assert(false)
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
			
		}
		return returnValue
	}
	
	func wordsModel(number:Int, count:Int, studyType:LHSQLStudyingModel.Progress, _ filter:String = "") -> LHSQLTableWordsAndStudy {
		let returnValue = LHSQLTableWordsAndStudy()
		if let db = self.sqlDataBase {
			var start = number
			var cnt = count
			let date1 = Date()
			while cnt > 0 {
				let array = self.wordModels(number:start, count:cnt, dataBase:db, studyType:studyType, filter)
				if array.count > 0 && array.count < cnt {
					print(array.count)
					cnt -= array.count
					start += array.count
				}
				else {
					cnt = 0
				}
				returnValue.rows.append(contentsOf:array.rows)
			}
			let date2 = Date()
			print(date2.timeIntervalSince(date1))
			
		}
		return returnValue
	}
	
	func wordsRandomModel(count:Int, studyType:LHSQLStudyingModel.Progress, _ filter:String = "") -> LHSQLTableWordsAndStudy {
		var returnValue = LHSQLTableWordsAndStudy()
		if let db = self.sqlDataBase {
			let date1 = Date()
			returnValue = self.wordsRandomModel(count:count, dataBase:db, studyType:studyType, filter)
			for value in returnValue.rows {
				self.wordModelFull(model: value.words)
			}
			let date2 = Date()
			print(date2.timeIntervalSince(date1))
			
		}
		return returnValue
	}
	
//	func save(_ model:LHSQLStudyingModel) {
////				let tableName = table.tableInfo.name
////				let command = "UPDATE `\(tableName)` SET studyGroup='Common 3000';"
////		
////		
//		
//		let tableName = LHSQLStudyingModel.table
//		var statement: OpaquePointer? = nil
//		static var sqlFields:[String] = ["id", "wordId", "word", "speech", "studyType", "defToEnCount", "enToDefCount", "studyGroup"]
//		let command:String = "UPDATE `\(tableName)` SET studyGroup='Common 3000'"
//		//select * from Definitions where Definitions.wordId = 5
//		
//		if sqlite3_prepare_v2(dataBase, command, -1, &statement, nil) != SQLITE_OK {
//			let errmsg = String(cString: sqlite3_errmsg(dataBase))
//			print("error preparing select: \(errmsg)")
//		}
//		
//		if SQLITE_OK != sqlite3_bind_int(statement, 1, wordId) {
//			self.printError(dataBase)
//		}
//		
//		while sqlite3_step(statement) == SQLITE_ROW {
//			let id = sqlite3_column_int(statement, 0)
//			let wordId = sqlite3_column_int(statement, 1)
//			let word = sqlite3_column_text(statement, 2)
//			let model = LHSQLDefinitionModel()
//			model.id = id
//			model.definition = String.init(cString:word!)
//			model.wordId = wordId
//			returnValue.append(model)
//		}
//		if sqlite3_finalize(statement) != SQLITE_OK {
//			self.printError(dataBase)
//		}
//		
//	}
	
	func save(_ model:LHSQLStudyingModel) {
		if model.id == 0 {
			self.append([model], table: LHSQLStudyingModel.table)
			
		}
		else {
			self.update(model)
		}
	}
	
	
	func update<Type:SQLModelProtocol>(_ model:Type){
		if let dataBase = self.sqlDataBase {
			assert(Type.sqlFields.contains("id"))
			let table = Type.table
			var fields = [String]()
			var fieldsNumbers = [Int32:String]()
			var lastNumber:Int32 = 1
			for field in Type.sqlFields {
				if field == "id" {
					continue
				}
				fields.append("`\(field)` = ?")
				fieldsNumbers[lastNumber] = field
				lastNumber += 1
			}
			fieldsNumbers[lastNumber] = "id"
			
			let fieldsCommand = fields.joined(separator: ", ")
			let command = "UPDATE \(table) SET \(fieldsCommand) where id = ?"
			print(command)
			var statement: OpaquePointer? = nil
			var testArra = [[CChar]?]()
			
			
			if sqlite3_prepare_v2(dataBase, command, -1, &statement, nil) != SQLITE_OK {
				self.printError(dataBase)
			}
			
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
			if sqlite3_reset(statement) != SQLITE_OK {
				self.printError(dataBase)
			}
			

			if sqlite3_finalize(statement) != SQLITE_OK {
				self.printError(dataBase)
			}
		}
	}
//	func wordsAndStudyTable(number:Int, count:Int) -> LHSQLTableWordsAndStudy {
//		let returnValue = LHSQLTableWordsAndStudy()
//		if let db = self.sqlDataBase {
//			var start = number
//			var cnt = count
//			let date1 = Date()
//			while cnt > 0 {
//				//select Words.id, Words.word, Words.transcription, Words.speech from Words inner JOIN Studying on Words.word = Studying.word and Words.speech = Studying.speech order by random() limit 1;
//				let array = self.wordModels(number:start, count:cnt, dataBase:db, filter)
//				if array.count > 0 && array.count < cnt {
//					print(array.count)
//					cnt -= array.count
//					start += array.count
//				}
//				else {
//					cnt = 0
//				}
//				returnValue.rows.append(contentsOf:array.rows)
//			}
//			let date2 = Date()
//			print(date2.timeIntervalSince(date1))
//			
//		}
//		return returnValue
//	}
	
	func wordModelFull(model:LHSQLWordModel) {
		if let db = self.sqlDataBase {
			model.definitions = self.definitionModels(wordId: model.id, dataBase:db)
		}
	}
	
	private func wordModels(number:Int, count:Int, dataBase:OpaquePointer, studyType:LHSQLStudyingModel.Progress, _ filter:String = "") -> LHSQLTableWordsAndStudy {
		assert(number >= 0)
		assert(count > 0)

		let returnValue = LHSQLTableWordsAndStudy()
		var statement: OpaquePointer? = nil
		
		let wordsTable = "Words"
		let studyTable = "Studying"
		let wordsKeys = "Words.id, Words.word, Words.transcription, Words.speech"
		let studyKeys = "Studying.id, Studying.studyType, Studying.defToEnCount, Studying.enToDefCount, Studying.studyGroup"
		
		let selectComand = "select \(wordsKeys), \(studyKeys)"
		let equalization = "\(wordsTable).word = \(studyTable).word and \(wordsTable).speech = \(studyTable).speech"
		var command = "\(selectComand) from \(wordsTable) LEFT OUTER JOIN \(studyTable) on \(equalization)"

//		command = "\(commandTemp) where \(wordsTable).word like ? limit ?, ?"
		
		
		var numberOfValue:Int32 = 1
		var cacheArray = [[CChar]?]()
		//make where
		var whereArray = [LHSQLFilter]()
		if studyType != .all {
			let filterModel = LHSQLFilter("Studying.studyType", "=", studyType.rawValue)
			whereArray.append(filterModel)
		}
		
		if !filter.isEmpty {
			let filterValue = filter + "%"
			let filterModel = LHSQLFilter("Words.word", "like", filterValue)
			whereArray.append(filterModel)
			//.cString(using: String.Encoding.utf8)
		}
		
		if whereArray.count > 0 {
			command.append(" where ")
		}
		for filterModel in whereArray {
			filterModel.number = numberOfValue
			if filterModel.number > 1 {
				command.append(" and ")
			}
			numberOfValue += 1
			command.append(filterModel.description)
		}
		command.append(" limit ?, ?")
		
		
		if sqlite3_prepare_v2(dataBase, command, -1, &statement, nil) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(dataBase))
			print("error preparing select: \(errmsg)")
		}
		
		for filterModel in whereArray {
			switch filterModel.value {
			case let value as String:
				let buff = value.cString(using: String.Encoding.utf8)
				//hack for keep data until it will be saved
				cacheArray.append(buff)
				if sqlite3_bind_text(statement, filterModel.number, buff, -1, nil) != SQLITE_OK {
					self.printError(dataBase)
				}
			case let value as Int32:
				if SQLITE_OK != sqlite3_bind_int(statement, filterModel.number, value) {
					self.printError(dataBase)
				}
			case _ as NSNull:
				if SQLITE_OK != sqlite3_bind_null(statement, filterModel.number) {
					self.printError(dataBase)
				}
			default:
				assert(false)
			}
			
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
		
		
		while sqlite3_step(statement) == SQLITE_ROW {
			let wordsModel = LHSQLWordModel()
			let studyingModel = LHSQLStudyingModel()
			//Words ["id", "word", "transcription", "speech"]
			wordsModel.id = sqlite3_column_int(statement, 0)
			wordsModel.word = String(cString:sqlite3_column_text(statement, 1))
			let transcription = sqlite3_column_text(statement, 2)
			wordsModel.speechId = sqlite3_column_int(statement, 3)
			
			//Studying ["id", "studyType", "defToEnCount", "enToDefCount", "studyGroup"]
			studyingModel.id = sqlite3_column_int(statement, 4)
			let studyType = sqlite3_column_int(statement, 5)
			studyingModel.defToEnCount = sqlite3_column_int(statement, 6)
			studyingModel.enToDefCount = sqlite3_column_int(statement, 7)
			let studyGroup = sqlite3_column_text(statement, 8)
			
			
			if transcription != nil {
				wordsModel.transcription = String.init(cString:transcription!)
			}
			
			studyingModel.studyType = LHSQLStudyingModel.Progress(rawValue:studyType)!
			if studyGroup != nil {
				studyingModel.studyGroup = String.init(cString:studyGroup!)
			}
			studyingModel.wordId = wordsModel.id
			studyingModel.word = wordsModel.word
			studyingModel.speech = wordsModel.speech
			returnValue.append((words:wordsModel, study:studyingModel))
		}
		if sqlite3_finalize(statement) != SQLITE_OK {
			self.printError(dataBase)
		}
		return returnValue
	}
	
	private func wordsRandomModel(count:Int, dataBase:OpaquePointer, studyType:LHSQLStudyingModel.Progress, _ filter:String = "") -> LHSQLTableWordsAndStudy {
		let returnValue = LHSQLTableWordsAndStudy()
		var statement: OpaquePointer? = nil
		
		let wordsTable = "Words"
		let studyTable = "Studying"
		let wordsKeys = "Words.id, Words.word, Words.transcription, Words.speech"
		let studyKeys = "Studying.id, Studying.studyType, Studying.defToEnCount, Studying.enToDefCount, Studying.studyGroup"
		
		let selectComand = "select \(wordsKeys), \(studyKeys)"
		let equalization = "\(wordsTable).word = \(studyTable).word and \(wordsTable).speech = \(studyTable).speech"
		var command = "\(selectComand) from \(wordsTable) LEFT OUTER JOIN \(studyTable) on \(equalization)"
		
		
		var numberOfValue:Int32 = 1
		var cacheArray = [[CChar]?]()
		//make where
		var whereArray = [LHSQLFilter]()
		if studyType != .all {
			let filterModel = LHSQLFilter("Studying.studyType", "=", studyType.rawValue)
			whereArray.append(filterModel)
		}
		
		if !filter.isEmpty {
			let filterValue = filter + "%"
			let filterModel = LHSQLFilter("Words.word", "like", filterValue)
			whereArray.append(filterModel)
			//.cString(using: String.Encoding.utf8)
		}
		
		if whereArray.count > 0 {
			command.append(" where ")
		}
		for filterModel in whereArray {
			filterModel.number = numberOfValue
			if filterModel.number > 1 {
				command.append(" and ")
			}
			numberOfValue += 1
			command.append(filterModel.description)
		}
		command.append(" order by random() limit ?")
		
		
		if sqlite3_prepare_v2(dataBase, command, -1, &statement, nil) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(dataBase))
			print("error preparing select: \(errmsg)")
		}
		
		for filterModel in whereArray {
			switch filterModel.value {
			case let value as String:
				let buff = value.cString(using: String.Encoding.utf8)
				//hack for keep data until it will be saved
				cacheArray.append(buff)
				if sqlite3_bind_text(statement, filterModel.number, buff, -1, nil) != SQLITE_OK {
					self.printError(dataBase)
				}
			case let value as Int32:
				if SQLITE_OK != sqlite3_bind_int(statement, filterModel.number, value) {
					self.printError(dataBase)
				}
			case _ as NSNull:
				if SQLITE_OK != sqlite3_bind_null(statement, filterModel.number) {
					self.printError(dataBase)
				}
			default:
				assert(false)
			}
			
		}
		
		let c = Int32(count)
		if SQLITE_OK != sqlite3_bind_int(statement, numberOfValue, c) {
			self.printError(dataBase)
		}
		
		
		while sqlite3_step(statement) == SQLITE_ROW {
			let wordsModel = LHSQLWordModel()
			let studyingModel = LHSQLStudyingModel()
			//Words ["id", "word", "transcription", "speech"]
			wordsModel.id = sqlite3_column_int(statement, 0)
			wordsModel.word = String(cString:sqlite3_column_text(statement, 1))
			let transcription = sqlite3_column_text(statement, 2)
			wordsModel.speechId = sqlite3_column_int(statement, 3)
			
			//Studying ["id", "studyType", "defToEnCount", "enToDefCount", "studyGroup"]
			studyingModel.id = sqlite3_column_int(statement, 4)
			let studyType = sqlite3_column_int(statement, 5)
			studyingModel.defToEnCount = sqlite3_column_int(statement, 6)
			studyingModel.enToDefCount = sqlite3_column_int(statement, 7)
			let studyGroup = sqlite3_column_text(statement, 8)
			
			
			if transcription != nil {
				wordsModel.transcription = String.init(cString:transcription!)
			}
			
			studyingModel.studyType = LHSQLStudyingModel.Progress(rawValue:studyType)!
			if studyGroup != nil {
				studyingModel.studyGroup = String.init(cString:studyGroup!)
			}
			studyingModel.wordId = wordsModel.id
			studyingModel.word = wordsModel.word
			studyingModel.speech = wordsModel.speech
			returnValue.append((words:wordsModel, study:studyingModel))
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
