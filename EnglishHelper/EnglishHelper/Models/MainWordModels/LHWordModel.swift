//
//  LHWordModel.swift
//  EnglishTableLerner
//
//  Created by Dzmitry Kudrashou on 2017-02-05.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

enum LHTypeSpeech : String {
	case Unknown
	case Noun
	case Pronoun
	case Verb
	case Adjective
	case Adverb
	case Preposition
	case Conjunction
	case Interjection
	case Article
	case Indefinite
	case Determiner
	case Predeterminer
	case Number
}

class LHWordModel: LHBaseModel, Comparable {
	
	var word:String
	var speech:LHTypeSpeech
	var transcription:String
	var translated = Set<String>()
	var wordDescriptions = Set<String>()
	var examples = Set<String>()
	var links = Set<String>()
	var iKnowThisWord = false
	var repeatsCountRu:Int = 0
	var repeatsCountEn:Int = 0
	var repeatsCountDescription:Int = 0
	var dateOfLastUsed:Date
	var isStudying = false
	
	//Initialisation's block
	init(word:String, speech:LHTypeSpeech) {
		self.word = word
		self.speech = speech
		self.dateOfLastUsed = Date()
		self.transcription = ""
	}
	
	//Work's blocks
	func updateFrom(_ wordModel:LHWordModel) {
		assert(self.word == self.word, "LHWordModel: different words")
		assert(self.speech == self.speech, "LHWordModel: different speeches")
		self.transcription = wordModel.transcription
		
		self.translated.formUnion(wordModel.translated)
		self.wordDescriptions.formUnion(wordModel.wordDescriptions)
		self.examples.formUnion(wordModel.examples)
		self.links.formUnion(wordModel.links)	
	}
	
	//NSObject's block
	var description: String {
		get {
			let translations = self.translated.joined(separator:", ")
			var returnValue = "\(self.word)\(self.transcription)(\(speech.rawValue)) - \(translations)"
			returnValue.append(self.transcription)
			return returnValue
		}
	}
	
	
	//Equatable's block
	public static func ==(lhs: LHWordModel, rhs: LHWordModel) -> Bool {
		return lhs.word == rhs.word && lhs.speech == rhs.speech
	}
	
	//Comparable's block
	public static func <(lhs: LHWordModel, rhs: LHWordModel) -> Bool {
		return lhs.word < rhs.word || (lhs.word == rhs.word && lhs.speech.rawValue < rhs.speech.rawValue)
	}
	
	public static func <=(lhs: LHWordModel, rhs: LHWordModel) -> Bool {
		return lhs.word < rhs.word || (lhs.word == rhs.word && lhs.speech.rawValue <= rhs.speech.rawValue)
	}
	
	public static func >=(lhs: LHWordModel, rhs: LHWordModel) -> Bool {
		return lhs.word > rhs.word || (lhs.word == rhs.word && lhs.speech.rawValue >= rhs.speech.rawValue)
	}
	
	public static func >(lhs: LHWordModel, rhs: LHWordModel) -> Bool {
		return lhs.word > rhs.word || (lhs.word == rhs.word && lhs.speech.rawValue > rhs.speech.rawValue)
	}
}
