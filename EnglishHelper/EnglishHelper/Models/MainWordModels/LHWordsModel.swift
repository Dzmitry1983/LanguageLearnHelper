//
//  LHWordsModel.swift
//  EnglishTableLerner
//
//  Created by Dzmitry Kudrashou on 2017-02-05.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHWordsModel: LHBaseModel {

	var wordsDictionary = Dictionary<LHDoubleDictionarysKey<LHTypeSpeech>, LHWordModel>()
	var isChaned = false
	
	var wordsCount:Int {
		get {
			return self.wordsDictionary.count
		}
	}
	
	//Work's blocks
	func add(_ word:String, speech:LHTypeSpeech) {
		self.updateWord(LHWordModel(word:word, speech:speech))
	}
	
	func add(_ wordModel:LHWordModel) {
		self.updateWord(wordModel)
	}
	
	func removeAll() {
		self.wordsDictionary.removeAll()
	}
	
	private func updateWord(_ wordModel:LHWordModel) {
		let key = LHDoubleDictionarysKey<LHTypeSpeech>(wordModel.word, wordModel.speech)
		if let model = self.wordsDictionary[key] {
			model.updateFrom(wordModel)
		}
		else {
			self.wordsDictionary[key] = wordModel
		}
		self.isChaned = true
	}
	
	
	//NSObject's block
	var description: String {
		get {
			var array = Array<String>()
			let models = self.wordsDictionary.values.sorted { (wordModel1, wordModel2) -> Bool in
				return wordModel1.word < wordModel2.word
			}
			for wordModel in models {
				array.append(wordModel.description)
			}
			return array.joined(separator:"\n")
		}
	}
}
