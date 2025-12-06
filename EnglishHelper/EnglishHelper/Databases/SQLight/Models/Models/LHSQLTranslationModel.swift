//
//  LHSQLTranslationModel.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-12.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHSQLTranslationModel: BaseSQLModel, SQLModelProtocol {
	var id:Int32 = 0
	var wordId:Int32 = 0
	var translation = ""
	
	static let table:String = "Translations"
	
	static let sqlCreateTable:String = "'id' INTEGER PRIMARY KEY AUTOINCREMENT, 'translation' TEXT NOT NULL, 'wordId' INTEGER NOT NULL"
	static let sqlFields:[String] = ["id","wordId","translation"]
	
	subscript(index: String) -> Any {
		let returnValue:Any
		switch index {
		case "id":
			returnValue = self.id == 0 ? NSNull() : self.id
		case "wordId":
			returnValue = self.wordId
		case "translation":
			returnValue = self.translation
		default:
			assert(false)
			returnValue = "NULL"
		}
		
		return returnValue
	}
}

