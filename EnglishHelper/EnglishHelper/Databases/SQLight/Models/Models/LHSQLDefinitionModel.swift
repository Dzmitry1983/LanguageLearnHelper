//
//  LHSQLDefinitionModel.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-12.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHSQLDefinitionModel: BaseSQLModel, SQLModelProtocol {
	var id:Int32 = 0
	var wordId:Int32 = 0
	var definition = ""
	
	static let table:String = "Definitions"
	
	static let sqlCreateTable:String = "`id` INTEGER PRIMARY KEY AUTOINCREMENT, `wordId` INTEGER NOT NULL, `definition` TEXT"
	static let sqlFields:[String] = ["id","definition","wordId"]
	
	subscript(index: String) -> Any {
		let returnValue:Any
		switch index {
		case "id":
			returnValue = self.id == 0 ? NSNull() : self.id
		case "wordId":
			returnValue = self.wordId
		case "definition":
			returnValue = self.definition
		default:
			assert(false)
			returnValue = "NULL"
		}
		
		return returnValue
	}
}
