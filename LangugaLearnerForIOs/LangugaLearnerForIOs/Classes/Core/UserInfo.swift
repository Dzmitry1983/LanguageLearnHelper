//
//  UserInfo.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-07.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class UserInfo {
	
	//properties
	static let instance:UserInfo = UserInfo()
	var wordsModel = LHWordsModel()
	private var wordsForStudy = [LHWordModel]()
	private var historyOfWords = [LHWordModel]()
	private var currentStudieWord:Int = 0
	private var isNeedLoad = true
	
	let defaultWordsFileName = "words.sqlite"
	let defaultStudyFileName = "studying.sqlite"
	
	var wordsFilePath:String {
		if let path = Bundle.main.path(forResource:defaultWordsFileName, ofType: nil) {
			return path
		}
		return ""
	}

	private (set) var studyFilePath:String = ""
	
	private (set) var count:Int = 0
	
	
	init() {
		self.copyStudyingToDocuments()
	}
	
	func copyStudyingToDocuments() {
		let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
		self.studyFilePath = documentDirectoryPath.appending("/\(defaultStudyFileName)")
		if !FileManager.default.fileExists(atPath: self.studyFilePath) {
			if let sourcePath = Bundle.main.path(forResource:defaultStudyFileName, ofType: nil) {
				let _ = try? FileManager.default.copyItem(atPath: sourcePath, toPath: self.studyFilePath)
			}
		}
		
	}
	
	
	func loadFile() {
		if !self.isNeedLoad {
			return
		}
		self.isNeedLoad = false
		if let loadaplePath = Bundle.main.path(forResource: "new", ofType: "json") {
			let serealiztor = LHJsonSerealization(filePath:loadaplePath)
			if let model = serealiztor.loadModel() {
				self.wordsModel = model
			}
		}
		
		
		
//		sqlDb
		
		var array = self.wordsModel.wordsDictionary.values.sorted()
		array = array.filter { (model) -> Bool in
			return model.translated.count > 0 || model.wordDescriptions.count > 0
		}
		self.wordsForStudy.append(contentsOf:array)
	}
	
	
	func nextWordForStudy() -> LHWordModel? {
		self.loadFile()
		var returnValue:LHWordModel? = nil
		self.currentStudieWord += 1
		if self.wordsForStudy.count > self.currentStudieWord {
			returnValue = self.wordsForStudy[self.currentStudieWord]
		}
		else {
			returnValue = self.wordsForStudy.first
			self.currentStudieWord = 0
		}
		return returnValue
	}
	
	func previewWordForStudy() -> LHWordModel? {
		self.loadFile()
		var returnValue:LHWordModel? = nil
		self.currentStudieWord -= 1
		if 0 > self.currentStudieWord {
			self.currentStudieWord = self.wordsForStudy.count == 0 ? 0 : self.wordsForStudy.count - 1
		}
		if self.wordsForStudy.count > self.currentStudieWord {
			returnValue = self.wordsForStudy[self.currentStudieWord]
		}
		return returnValue
		
	}
	
	func saveFile() {
//		let serealiztor = LHJsonSerealization(filePath:self.savedPath)
//		serealiztor.saveModel(wordsModel: self.wordsModel)
	}
}
