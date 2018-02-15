//
//  BaseSQLModel.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-12.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class BaseSQLModel {
	
	//MARK: - support
	func speechTypeFromInt(_ number:Int32) -> LHTypeSpeech {
		var returnValue:LHTypeSpeech = .Unknown
		switch number {
		case 1:
			returnValue = .Noun
		case 2:
			returnValue = .Verb
		case 3:
			returnValue = .Adjective
		case 4:
			returnValue = .Adverb
		default:
			returnValue = .Unknown
		}
		return returnValue
	}
	
	func intFromSpeechType(_ number:LHTypeSpeech) -> Int32 {
		var returnValue:Int32 = 0
		switch number {
		case .Noun:
			returnValue = 1
		case .Verb:
			returnValue = 2
		case .Adjective:
			returnValue = 3
		case .Adverb:
			returnValue = 4
		default:
			returnValue = 0
		}
		return returnValue
	}
	
	
}
