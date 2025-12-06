//
//  LLWordsControllerProtocol.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-14.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

enum StudyWodrsType : Int {
	case all = 0
	case studying
	case studied
}

protocol LLWordModelProtocol {
	var word:String {get}
	var speech:String {get}
	var transcription:String {get}
	var definitions:[String] {get}
	var studyingGroup:String {get}
	var studyingType:Int {get set}
	var enToDefCount:Int {get set}
	var defToEnCount:Int {get set}
}

protocol LLSectionModelProtocol {
	var name:String {get}
	var count:Int {get}
}

protocol LLTableControllerProtocol {
	func load()
	func close()
}

protocol LLWordsControllerProtocol : LLTableControllerProtocol {
	func next() -> LLWordModelProtocol?
	func last() -> LLWordModelProtocol?
	func saveModel(_ model:LLWordModelProtocol)
	var filterWord:String {get set}
	
}
