//
//  LHJsonSerealization.swift
//  EnglishTableLerner
//
//  Created by Dzmitry Kudrashou on 2017-02-05.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHJsonSerealization {
	//Properties
	var url:URL
	
	//Initialisation's blocks
	
	init(filePath:String) {
		self.url = URL(fileURLWithPath:filePath)
	}
	
	init(url:URL) {
		self.url = url
	}
	
	
	//Serealization's blocks
	
	func loadModel() -> LHWordsModel? {
		let returnValue:LHWordsModel?
		do {
			let data = try Data(contentsOf:url)
			let jsonResult = try JSONSerialization.jsonObject(with: data)
			if let dictionary = jsonResult as? Dictionary<String, Any> {
				returnValue = self.wordsModelFrom(dictionary:dictionary)
			}
			else {
				returnValue = nil
			}
		}
		catch {
			returnValue = nil
		}
		return returnValue
	}
	
	func saveModel(wordsModel:LHWordsModel) -> Bool {
		let forSave = self.dictionryFrom(wordsModel:wordsModel)
		var isValidJSONObject = JSONSerialization.isValidJSONObject(forSave)
		assert(isValidJSONObject, "isValidJSONObject == false")
		if (isValidJSONObject) {
			do {
				let data = try JSONSerialization.data(withJSONObject:forSave)
				try data.write(to:url)
			}
			catch {
				isValidJSONObject = false
			}
		}
		return isValidJSONObject
	}
	
	enum TypeDictionaryKeys : String {
		case LHWordsModel
		case LHWordModel
		case Word
		case Speech
		case Transcription
		case Translated
		case WordDescriptions
		case Examples
		case Links
		case IKnowThisWord
		case IsStudying
		case RepeatsCountRu
		case RepeatsCountEn
		case RepeatsCountDescription
		case DateOfLastUsed
	}
	
	private func dictionryFrom(wordsModel:LHWordsModel) -> Dictionary<String, Any> {
		var returnValue = Dictionary<String, Any>()
		var wordsModelDictionary = Dictionary<String, Any>()
		var modelsArray = Array<Any>()
		for wordModel in wordsModel.wordsDictionary.values {
			let dictionary = self.dictionryFrom(wordModel:wordModel)
			modelsArray.append(dictionary)
		}
		wordsModelDictionary[TypeDictionaryKeys.LHWordModel.rawValue] = modelsArray
		returnValue[TypeDictionaryKeys.LHWordsModel.rawValue] = wordsModelDictionary
		return returnValue
	}
	
	private func wordsModelFrom(dictionary:Dictionary<String, Any>) -> LHWordsModel {
		let returnValue = LHWordsModel()
		let wordsModeldictionary = self.dictionaryFrom(dictionary:dictionary, key:TypeDictionaryKeys.LHWordsModel.rawValue)
		let array = self.arrayFrom(dictionary:wordsModeldictionary, key:TypeDictionaryKeys.LHWordModel.rawValue)
		for value in array {
			if let dictionary = value as? Dictionary<String, Any> {
				let wordModel = self.wordModelFrom(dictionary:dictionary)
				returnValue.add(wordModel)
			}
		}
		return returnValue
	}
	
	
	private func dictionryFrom(wordModel:LHWordModel) -> Dictionary<String, Any> {
		var returnValue = Dictionary<String, Any>()
		returnValue[TypeDictionaryKeys.Word.rawValue] = wordModel.word
		returnValue[TypeDictionaryKeys.Word.rawValue] = wordModel.word
		returnValue[TypeDictionaryKeys.Speech.rawValue] = wordModel.speech.rawValue
		returnValue[TypeDictionaryKeys.Transcription.rawValue] = wordModel.transcription
		returnValue[TypeDictionaryKeys.Translated.rawValue] = Array(wordModel.translated)
		returnValue[TypeDictionaryKeys.WordDescriptions.rawValue] = Array(wordModel.wordDescriptions)
		returnValue[TypeDictionaryKeys.Examples.rawValue] = Array(wordModel.examples)
		returnValue[TypeDictionaryKeys.Links.rawValue] = Array(wordModel.links)
		returnValue[TypeDictionaryKeys.IKnowThisWord.rawValue] = NSNumber(value:wordModel.iKnowThisWord)
		returnValue[TypeDictionaryKeys.IsStudying.rawValue] = NSNumber(value:wordModel.isStudying)
		returnValue[TypeDictionaryKeys.RepeatsCountRu.rawValue] = NSNumber(value:wordModel.repeatsCountRu)
		returnValue[TypeDictionaryKeys.RepeatsCountEn.rawValue] = NSNumber(value:wordModel.repeatsCountEn)
		returnValue[TypeDictionaryKeys.RepeatsCountDescription.rawValue] = NSNumber(value:wordModel.repeatsCountDescription)
		returnValue[TypeDictionaryKeys.DateOfLastUsed.rawValue] = NSNumber(value:wordModel.dateOfLastUsed.timeIntervalSince1970)
		return returnValue
	}
	
	
	
	
	private func wordModelFrom(dictionary:Dictionary<String, Any>) -> LHWordModel {
		let word = self.stringFrom(dictionary:dictionary, key:TypeDictionaryKeys.Word.rawValue)
		let speech:LHTypeSpeech = self.speechFrom(dictionary:dictionary, key:TypeDictionaryKeys.Speech.rawValue)
		let transcription = self.stringFrom(dictionary:dictionary, key:TypeDictionaryKeys.Transcription.rawValue)
		let translated = self.setFrom(dictionary:dictionary, key:TypeDictionaryKeys.Translated.rawValue)
		let wordDescriptions = self.setFrom(dictionary:dictionary, key:TypeDictionaryKeys.WordDescriptions.rawValue)
		let examples = self.setFrom(dictionary:dictionary, key:TypeDictionaryKeys.Examples.rawValue)
		let links = self.setFrom(dictionary:dictionary, key:TypeDictionaryKeys.Links.rawValue)
		let iKnowThisWord = self.boolFrom(dictionary:dictionary, key:TypeDictionaryKeys.IKnowThisWord.rawValue)
		let isStudying = self.boolFrom(dictionary:dictionary, key:TypeDictionaryKeys.IsStudying.rawValue)
		let repeatsCountRu = self.intFrom(dictionary:dictionary, key:TypeDictionaryKeys.RepeatsCountRu.rawValue)
		let repeatsCountEn = self.intFrom(dictionary:dictionary, key:TypeDictionaryKeys.RepeatsCountEn.rawValue)
		let repeatsCountDescription = self.intFrom(dictionary:dictionary, key:TypeDictionaryKeys.RepeatsCountDescription.rawValue)
		let dateOfLastUsed = self.dateFrom(dictionary:dictionary, key:TypeDictionaryKeys.DateOfLastUsed.rawValue)
		
		
		let returnValue = LHWordModel(word:word, speech:speech)
		returnValue.transcription = transcription
		returnValue.translated = translated
		returnValue.wordDescriptions = wordDescriptions
		returnValue.examples = examples
		returnValue.links = links
		returnValue.iKnowThisWord = iKnowThisWord
		returnValue.isStudying = isStudying
		returnValue.repeatsCountRu = repeatsCountRu
		returnValue.repeatsCountEn = repeatsCountEn
		returnValue.repeatsCountDescription = repeatsCountDescription
		returnValue.dateOfLastUsed = dateOfLastUsed
		return returnValue
	}
	
	
	//funcions for convert from Any to Type
	private func stringFrom(dictionary:Dictionary<String, Any>, key:String) -> String {
		let returnValue:String
		if let value = dictionary[key] as? String {
			returnValue = value
		}
		else {
			returnValue = ""
		}
		return returnValue
	}
	
	private func speechFrom(dictionary:Dictionary<String, Any>, key:String) -> LHTypeSpeech {
		let returnValue:LHTypeSpeech
		let textValue = self.stringFrom(dictionary: dictionary, key: key)
		if let speech = LHTypeSpeech(rawValue: textValue) {
			returnValue = speech
		}
		else {
			returnValue = LHTypeSpeech.Unknown
		}
		return returnValue
	}
	
	
	private func setFrom(dictionary:Dictionary<String, Any>, key:String) -> Set<String> {
		var returnVaue = Set<String>()
		if let propertyValue:Array<String> = dictionary[key] as? Array<String> {
			returnVaue = Set(propertyValue)
		}
		return returnVaue
	}
	
	private func arrayFrom(dictionary:Dictionary<String, Any>, key:String) -> Array<Any> {
		var returnVaue = Array<Any>()
		if let propertyValue = dictionary[key] as? Array<Any> {
			returnVaue = propertyValue
		}
		return returnVaue
	}
	
	private func dictionaryFrom(dictionary:Dictionary<String, Any>, key:String) -> Dictionary<String, Any> {
		var returnVaue = Dictionary<String, Any>()
		if let propertyValue = dictionary[key] as? Dictionary<String, Any> {
			returnVaue = propertyValue
		}
		return returnVaue
	}
	
	private func boolFrom(dictionary:Dictionary<String, Any>, key:String) -> Bool {
		let returnValue:Bool
		if let value = dictionary[key] as? NSNumber {
			returnValue = value.boolValue
		}
		else {
			returnValue = false
		}
		return returnValue
	}
	
	private func intFrom(dictionary:Dictionary<String, Any>, key:String) -> Int {
		let returnValue:Int
		if let value = dictionary[key] as? NSNumber {
			returnValue = value.intValue
		}
		else {
			returnValue = 0
		}
		return returnValue
	}
	
	private func dateFrom(dictionary:Dictionary<String, Any>, key:String) -> Date {
		let returnValue:Date
		if let value = dictionary[key] as? NSNumber {
			returnValue = Date.init(timeIntervalSince1970:value.doubleValue)
		}
		else {
			returnValue = Date.init(timeIntervalSince1970:0)
		}
		return returnValue
	}
}
