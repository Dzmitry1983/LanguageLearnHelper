//
//  LHSQLWordModel.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-12.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHSQLWordModel: BaseSQLModel, SQLModelProtocol {
	
	var id:Int32 = 0
	var word = ""
	var transcription:String? = nil
	var speech:LHTypeSpeech = .Unknown
	var speechId:Int32 {
		get {
			return self.intFromSpeechType(self.speech)
		}
		set (value) {
			self.speech = self.speechTypeFromInt(value)
		}
	}
	
	var definitions = [LHSQLDefinitionModel]()
	var translations = [LHSQLTranslationModel]()
	
	static var table:String = "Words"
	
	static var sqlCreateTable:String = "`id` INTEGER PRIMARY KEY AUTOINCREMENT, `word` TEXT NOT NULL, `transcription` TEXT, `speech` INTEGER NOT NULL"
	static var sqlFields:[String] = ["id", "word", "transcription", "speech"]	
	
	subscript(index: String) -> Any {
		let returnValue:Any
		switch index {
		case "id":
			returnValue = self.id == 0 ? NSNull() : self.id
		case "word":
			returnValue = self.word
		case "speech":
			returnValue = self.speechId
		case "transcription":
			returnValue = self.transcription == nil ? NSNull() : self.transcription!
		default:
			assert(false)
			returnValue = "NULL"
		}
		
		return returnValue
	}
	
	
	
	
}
