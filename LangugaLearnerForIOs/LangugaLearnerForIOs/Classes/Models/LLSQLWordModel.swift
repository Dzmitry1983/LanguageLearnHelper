//
//  LLWordModel.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-14.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import UIKit

class LLSQLWordModel: LLBaseModel, LLWordModelProtocol {
	var word:String {
			return self.sqlWordModel.word
	}
	var speech:String {
			return self.sqlWordModel.speech.rawValue
	}
	
	var studyingGroup:String {
		let returnValue:String
		if let group = self.sqlStudyingModel.studyGroup {
			returnValue = group
		}
		else {
			returnValue = ""
		}
		return returnValue
	}
	
	var definitions:[String] {
		get {
			var returnValue = [String]()
			for model in self.sqlWordModel.definitions {
				returnValue.append(model.definition)
			}
			return returnValue
		}
	}
	
	var studyingType: Int {
		get {
			return Int(self.sqlStudyingModel.studyType.rawValue)
		}
		set (value) {
			self.sqlStudyingModel.studyType = LHSQLStudyingModel.Progress(rawValue:Int32(value))!
		}
	}
	
	var enToDefCount:Int {
		get {
			return Int(self.sqlStudyingModel.enToDefCount)
		}
		set (value) {
			self.sqlStudyingModel.enToDefCount = Int32(value)
		}
	}
	var defToEnCount:Int {
		get {
			return Int(self.sqlStudyingModel.defToEnCount)
		}
		set (value) {
			self.sqlStudyingModel.defToEnCount = Int32(value)
		}
	}
	
	var transcription:String {
		return self.sqlWordModel.transcription == nil ? "" : self.sqlWordModel.transcription!
	}
	var sqlWordModel:LHSQLWordModel
	var sqlStudyingModel:LHSQLStudyingModel
	
	init(sqlWordModel:LHSQLWordModel, sqlStudyingModel:LHSQLStudyingModel) {
		self.sqlWordModel = sqlWordModel
		self.sqlStudyingModel = sqlStudyingModel
	
	}
}
