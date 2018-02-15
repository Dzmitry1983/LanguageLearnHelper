//
//  LHIndexModel.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-08.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHIndexModel : LHBasePrinstonModel {
	private(set) var word:String = ""
	private(set) var speech:LHTypeSpeech = .Unknown
	private(set) var links = [String]()
	
	override func parseLine(line:String) {
//		assert(line.contains("@"))
		self.links.removeAll()
		let array = line.components(separatedBy:" ")
		assert(array.count > 5)
		self.word = array[0].replacingOccurrences(of:"_", with:" ")
		self.speech = self.updateSpeechType(number:array[1])
		
		assert(self.word.lengthOfBytes(using: String.Encoding.utf8) > 0)
		assert(self.speech != .Unknown)
		for number in 2..<array.count {
			let text = array[number]
			if text.lengthOfBytes(using: String.Encoding.utf8) > 1 {
				self.links.append(text)
			}
		}
//		abandon				n 2 1 @ 2 1 04885398 07481223
//		abandoned_infant	n 1 1 @ 1 0 10107883
//		abandoned_person	n 1 2 @ ~ 1 0 09753930
//		abandoned_ship		n 1 1 @ 1 0 02666501
//		abandonment			n 3 3 @ ~ + 3 2 00204439 00055315 00091013
		
		

	}
	private func updateSpeechType(number:String) -> LHTypeSpeech {
		var returnValue:LHTypeSpeech = .Unknown
		switch number {
		case "n":
			returnValue = .Noun
		case "v":
			returnValue = .Verb
		case "a":
			returnValue = .Adjective
		case "r":
			returnValue = .Adverb
		default:
			returnValue = .Unknown
		}
		return returnValue
	}
}
