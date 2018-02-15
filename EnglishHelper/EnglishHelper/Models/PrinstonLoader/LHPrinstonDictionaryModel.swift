//
//  LHPrinstonDictionaryModel.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-08.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHPrinstonDictionaryModel {
	
	var indexesSense = [LHIndexSenseModel]()
	var indexAdj = [LHIndexModel]()
	var indexAdv = [LHIndexModel]()
	var indexNouns = [LHIndexModel]()
	var indexVerb = [LHIndexModel]()
	var dataAdj = [String:LHDataModel]()
	var dataAdv = [String:LHDataModel]()
	var dataNouns = [String:LHDataModel]()
	var dataVerb = [String:LHDataModel]()
	var results = [LHPrinstonResultModel]()
	
	
	

	func loadAll() {
//		let date1 = Date.init()
//		self.indexesSense = self.loadSense(fileName:"index.sense")
//		let date2 = Date.init()
		self.dataAdj = self.loadData(fileName:"data.adj")
		self.dataAdv = self.loadData(fileName:"data.adv")
		self.dataNouns = self.loadData(fileName:"data.noun")
		self.dataVerb = self.loadData(fileName:"data.verb")
		self.indexAdj = self.loadIndex(fileName:"index.adj")
		self.indexAdv = self.loadIndex(fileName:"index.adv")
		self.indexNouns = self.loadIndex(fileName:"index.noun")
		self.indexVerb = self.loadIndex(fileName:"index.verb")
		self.results = self.mergeAll()
		self.results.sort { (left, right) -> Bool in
			left.word < right.word
		}
		print(self.indexesSense.count)
		print(self.dataAdj.count)
		print(self.dataAdv.count)
		print(self.dataNouns.count)
		print(self.dataVerb.count)
		print(self.indexAdj.count)
		print(self.indexAdv.count)
		print(self.indexNouns.count)
		print(self.indexVerb.count)
//		print(date2.timeIntervalSince(date1))
	}
	
	private func loadSense (fileName:String) -> [LHIndexSenseModel] {
		var returnValue = [LHIndexSenseModel]()
		if let stringArray = self.loadFile(fileName:fileName) {
			assert(stringArray.count > 0)
			for line in stringArray {
				if line.isEmpty {
					continue
				}
				let sense = LHIndexSenseModel.init(line)
				returnValue.append(sense)
			}
		}
		return returnValue
	}
	
	private func loadData(fileName:String) -> [String:LHDataModel] {
		var returnValue = [String:LHDataModel]()
		if let stringArray = self.loadFile(fileName:fileName) {
			assert(stringArray.count > 0)
			for line in stringArray {
				if line.isEmpty || line.hasPrefix("  ") {
					continue
				}
				let sense = LHDataModel.init(line)
				assert(returnValue[sense.address] == nil, "double address")
				returnValue[sense.address] = sense
			}
		}
		return returnValue
	}
	
	private func loadIndex(fileName:String) -> [LHIndexModel]{
		var returnValue = [LHIndexModel]()
		if let stringArray = self.loadFile(fileName:fileName) {
			assert(stringArray.count > 0)
			for line in stringArray {
				if line.isEmpty || line.hasPrefix("  ") {
					continue
				}
				let sense = LHIndexModel.init(line)
				returnValue.append(sense)
			}
		}
		return returnValue
	}
	
	private func loadFile(fileName:String) -> [String]? {
		var returnValue:[String]? = nil
		
		if let path = Bundle.main.path(forResource:fileName, ofType:"") {
			print("Path is \(path)")
			if let url = URL(string:"file://\(path)") {
				do {
					let stringText = try String.init(contentsOf:url)
					returnValue = stringText.components(separatedBy:"\n")
				}
				catch  {
					print("Error info: \(error)")
				}
			}
		}
		else {
			print("Could not find path")
		}
		return returnValue
	}
	
	private func mergeAll() -> [LHPrinstonResultModel] {
		var returnValue = [LHPrinstonResultModel]()
		let noun = mergeFrom(index:self.indexNouns, data:self.dataNouns)
		let verb = mergeFrom(index:self.indexVerb, data:self.dataVerb)
		let adj = mergeFrom(index:self.indexAdj, data:self.dataAdj)
		let adv = mergeFrom(index:self.indexAdv, data:self.dataAdv)
		returnValue.append(contentsOf:noun)
		returnValue.append(contentsOf:verb)
		returnValue.append(contentsOf:adj)
		returnValue.append(contentsOf:adv)
//		for word in self.indexNouns {
//			let value = LHPrinstonResultModel()
//			value.word = word.word
//			value.speechType = word.speech
//			for link in word.links {
//				if let text = self.dataNouns[link]?.text {
//					value.texts.append(text)
//				}
//			}
//			returnValue.append(value)
//		}
//		
		return returnValue
	}
	
	private func mergeFrom(index:[LHIndexModel], data:[String:LHDataModel]) -> [LHPrinstonResultModel] {
		var returnValue = [LHPrinstonResultModel]()
		
		for word in index {
			let value = LHPrinstonResultModel()
			value.word = word.word
			value.speechType = word.speech
			for link in word.links {
				if let text = data[link]?.text {
					value.texts.append(text)
				}
			}
			returnValue.append(value)
		}
		return returnValue
	}
}





//index.sense
/*
abandon%1:07:00:: 04885398 1 4
abandon%1:12:00:: 07481223 2 0
abandon%2:31:00:: 00614057 5 3
abandon%2:31:01:: 00613393 4 5
abandon%2:38:00:: 02076676 3 6
abandon%2:40:00:: 02228031 1 10
abandon%2:40:01:: 02227741 2 6
abandoned%5:00:00:uninhabited:00 01313004 1 1
abandoned%5:00:00:uninhibited:00 01317231 2 0
abandoned_infant%1:18:00:: 10107883 1 0
abandoned_person%1:18:00:: 09753930 1 0
abandoned_ship%1:06:00:: 02666501 1 0
abandonment%1:04:01:: 00055315 2 1
abandonment%1:04:02:: 00091013 3 0
abandonment%1:04:03:: 00204439 1 3
*/
//index.adj
/*
abandoned a 2 1 & 2 1 01313004 01317231
*/

//index.noun
/*
abandon n 2 1 @ 2 1 04885398 07481223
abandoned_infant n 1 1 @ 1 0 10107883
abandoned_person n 1 2 @ ~ 1 0 09753930
abandoned_ship n 1 1 @ 1 0 02666501
abandonment n 3 3 @ ~ + 3 2 00204439 00055315 00091013

*/
//index.verb
/*
abandon v 5 4 @ ~ $ + 5 5 02228031 02227741 02076676 00613393 00614057
*/
//data.noun
/*
04885398 07 n 03 abandon 0 wantonness 0 unconstraint 0 002 @ 04885091 n 0000 + 01559270 a 0203 | the trait of lacking restraint or control; reckless freedom from inhibition or worry; "she danced with abandon"

04885091 07 n 01 unrestraint 0 006 @ 04884450 n 0000 ! 04882968 n 0101 ~ 04885271 n 0000 ~ 04885398 n 0000 ~ 04885609 n 0000 ~ 04885990 n 0000 | the quality of lacking restraint
*/
