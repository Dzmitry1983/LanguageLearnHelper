//
//  LHPrinstonResultModel.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-11.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHPrinstonResultModel {
	var word:String = ""
	var speechType:LHTypeSpeech = .Noun
	var texts = [String]()
	var lexicographer:String = ""
	
	var description:String {
		get {
			return "\(self.word) \(self.speechType.rawValue) \(self.texts)"
		}
	}
}
