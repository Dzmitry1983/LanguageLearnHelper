//
//  LLSQLWordsTableControllerModel.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-20.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import UIKit

class LLSQLWordsTableControllerModel: LLTableControllerProtocol {
	
	private var sections = [LLSectionModel]()
	private var wordsCurrent = [LLSQLWordModel]()
	private var wordsBefore = [LLSQLWordModel]()
	private var wordsAfter = [LLSQLWordModel]()
	
	var studyType:StudyWodrsType = .all
	var count:Int {
		get {
			return self.sections.count
		}
	}
	var filterWord:String = "" {
		didSet {
			self.update()
		}
	}
	var numberPreloadedWords:Int = 100
	var currentOffset:Int = 0
	var sqlWordsManager:LHSQLWordsAndStudyProtocol!
	
	subscript(index: Int) -> LLSectionModel {
		get {
			return self.sections[index]
		}
	}
	
	subscript(first: Int, seccond:Int) -> LLSQLWordModel {
		get {
			var offset = 0
			for number in 0..<first {
				offset += self.sections[number].count
			}
			offset += seccond
			var number = offset - self.currentOffset
			if number < 0 {
				number += self.wordsBefore.count
				self.currentOffset -= self.wordsBefore.count
				self.wordsAfter = self.wordsCurrent
				self.wordsCurrent = self.wordsBefore
				self.updateWordsBefore()
			}
			if number >= self.wordsCurrent.count && self.wordsAfter.count > 0 {
				number -= self.wordsCurrent.count
				self.currentOffset += self.wordsCurrent.count
				self.wordsBefore = self.wordsCurrent
				self.wordsCurrent = self.wordsAfter
				self.updateWordsAfter()
				
			}
			let returnValue: LLSQLWordModel
			if self.wordsCurrent.count > number && number >= 0 {
				returnValue = self.wordsCurrent[number]
			}
			else {
				returnValue = self.wordsCurrent.first!
			}
			return returnValue
		}
	}
	
    @MainActor
    func load() {
		self.sqlWordsManager = LHSQLWordsAndStudyManager(UserInfo.instance.wordsFilePath)
		self.sqlWordsManager.attachDatabase(UserInfo.instance.studyFilePath, databaseName:"study")
		self.update()
	}
	
	func close() {
		self.sqlWordsManager = nil
	}
	
	func update() {
		self.sections.removeAll()
		let study = self.studyTypeFrom(self.studyType)
		let array = self.sqlWordsManager.firstLetters(studyType:study,  self.filterWord)
		for letter in array {
			self.sections.append(LLSectionModel(name:letter.charater, count:letter.count))
		}
		self.currentOffset = 0
		self.updateWordsBefore()
		self.updateWordsCurrent()
		self.updateWordsAfter()
	}
	
	func updateModel(_ model: LLSQLWordModel) {
        self.sqlWordsManager.wordModelFull(model: model.sqlWordModel)
	}
	
	private func updateWordsBefore() {
		self.wordsBefore.removeAll()
		if (self.currentOffset > 0) {
			var start = self.currentOffset - self.numberPreloadedWords
			var count = self.numberPreloadedWords
			if start < 0 {
				count += start
				start = 0
			}
			self.wordsBefore = self.wordsFromSql(startIndex:start, count:count)
		}
		
	}
	
	private func updateWordsAfter() {
		let start = self.wordsCurrent.count + self.currentOffset
		let count = self.numberPreloadedWords
		self.wordsAfter = self.wordsFromSql(startIndex:start, count:count)
	}
	
	private func updateWordsCurrent() {
		self.wordsCurrent = self.wordsFromSql(startIndex:self.currentOffset, count:self.numberPreloadedWords)
	}
	
	private func wordsFromSql(startIndex:Int, count:Int) -> [LLSQLWordModel] {
		var returnValue = [LLSQLWordModel]()
		assert(count > 0)
		assert(startIndex >= 0)
		print("start = \(startIndex), count = \(count)")
		let study = self.studyTypeFrom(self.studyType)
		let words = self.sqlWordsManager.wordsModel(number: startIndex, count: count, studyType:study , self.filterWord)
		print("count = \(words.count)")
		for word in words.rows {
			let new = LLSQLWordModel(sqlWordModel: word.words, sqlStudyingModel: word.study)
			returnValue.append(new)
		}
		return returnValue
	}
	
	private func studyTypeFrom(_ studyWodrsType:StudyWodrsType) -> LHSQLStudyingModel.Progress {
		let returnValue: LHSQLStudyingModel.Progress
		switch studyWodrsType {
		case .all:
			returnValue = .all
		case .studying:
			returnValue = .studying
		case .studied:
			returnValue = .studied
		}
		return returnValue
	}
	
	func saveModel(_ model:LLSQLWordModel) {
        self.sqlWordsManager.save(model.sqlStudyingModel)
	}
}
