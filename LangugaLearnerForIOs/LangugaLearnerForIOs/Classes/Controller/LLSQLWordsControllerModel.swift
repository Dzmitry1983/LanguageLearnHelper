//
//  LLWordsModel.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-14.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import UIKit

class LLSQLWordsControllerModel: LLTableControllerProtocol {

	private let countOfWords = 5
	private var modelsArray = [LLSQLWordModel]()
	
	var filterWord = ""
	
	var sqlWordsManager: LHSQLWordsAndStudyManager!
	
    @MainActor
    func load() {
		self.sqlWordsManager = LHSQLWordsAndStudyManager(UserInfo.instance.wordsFilePath)
		self.sqlWordsManager.attachDatabase(UserInfo.instance.studyFilePath, databaseName:"study")
		
		self.modelsArray.removeAll()
		let words = self.sqlWordsManager.wordsRandomModel(count:countOfWords, studyType:.studying, self.filterWord)
		for word in words.rows {
			let model = LLSQLWordModel(sqlWordModel: word.words, sqlStudyingModel: word.study)
			self.modelsArray.append(model)
		}
		
		print("tables = ", self.sqlWordsManager.tables())
	}
	
	func close() {
		self.sqlWordsManager = nil
	}
	
	func next() -> LLSQLWordModel? {
		let words = self.sqlWordsManager.wordsRandomModel(count:1, studyType:.studying, self.filterWord)
		var returnValue:LLSQLWordModel? = nil
		print("count = \(words.count)")
		if words.count > 0 {
			let model = LLSQLWordModel(sqlWordModel: words[0].words, sqlStudyingModel: words[0].study)
			self.modelsArray.append(model)
		}
		
		if self.modelsArray.count > 0 {
			self.modelsArray.removeFirst()
		}
		let number = self.modelsArray.count / 2
		if number < self.modelsArray.count {
			returnValue = self.modelsArray[self.modelsArray.count / 2]
		}
		return returnValue
	}
	
	func last() -> LLSQLWordModel? {
		let words = self.sqlWordsManager.wordsRandomModel(count:1, studyType:.studying, self.filterWord)
		var returnValue:LLSQLWordModel? = nil
		print("count = \(words.count)")
		if words.count > 0 {
			let model = LLSQLWordModel(sqlWordModel: words[0].words, sqlStudyingModel: words[0].study)
			self.modelsArray.insert(model, at: 0)
		}
		
		self.modelsArray.removeLast()
		let number = self.modelsArray.count / 2
		if number < self.modelsArray.count {
			returnValue = self.modelsArray[self.modelsArray.count / 2]
		}
		
		return returnValue
	}
	
	func saveModel(_ model:LLSQLWordModel) {
        self.sqlWordsManager.save(model.sqlStudyingModel)
	}
}
