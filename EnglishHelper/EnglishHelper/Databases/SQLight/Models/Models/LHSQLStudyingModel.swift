//
//  LHSQLStudyingModel.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-17.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHSQLStudyingModel: BaseSQLModel, SQLModelProtocol {
	enum Progress : Int32 {
		case none = 0
		case studying = 1
		case studied = 2
		case all
	}
	
	var id:Int32 = 0
	var wordId:Int32 = 0
	var word = ""
	var speech:LHTypeSpeech = .Unknown
	var speechId:Int32 {
		return self.intFromSpeechType(self.speech)
	}
	var studyType:Progress = .none
	var defToEnCount:Int32 = 0
	var enToDefCount:Int32 = 0
	var studyGroup:String? = nil
	
	
	
	
	static let table: String = "Studying"
	
	static let sqlCreateTable:String = "`id` INTEGER PRIMARY KEY AUTOINCREMENT, `wordId` INTEGER,`word` TEXT NOT NULL, `speech` INTEGER NOT NULL, `studyType` INTEGER, `defToEnCount` INTEGER, `enToDefCount` INTEGER, `studyGroup` TEXT"
	static let sqlFields:[String] = ["id", "wordId", "word", "speech", "studyType", "defToEnCount", "enToDefCount", "studyGroup"]
	
	subscript(index: String) -> Any {
		let returnValue:Any
		switch index {
		case "id":
			returnValue = self.id == 0 ? NSNull() : self.id
		case "wordId":
			returnValue = self.wordId
		case "word":
			returnValue = self.word
		case "speech":
			returnValue = self.speechId
		case "studyType":
			returnValue = self.studyType.rawValue
		case "defToEnCount":
			returnValue = self.defToEnCount
		case "enToDefCount":
			returnValue = self.enToDefCount
		case "studyGroup":
			returnValue = self.studyGroup == nil ? NSNull() : self.studyGroup!
		default:
			assert(false)
			returnValue = "NULL"
		}
		
		return returnValue
	}
}
