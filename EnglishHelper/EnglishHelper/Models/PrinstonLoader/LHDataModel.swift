//
//  LHDataModel.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-08.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

internal class LHDataModel : LHBasePrinstonModel {
	private(set) var address:String = ""
	private(set) var text:String = ""
	private(set) var information:String = ""
	
	override func parseLine(line:String) {
		let lines = line.components(separatedBy:"|")
		assert(lines.count == 2)
		self.text = lines[1]
		var array = lines[0].components(separatedBy:" ")
		self.address = array.removeFirst()
		self.information = array.joined(separator:" ")
		
//		04885398 07 n 03 abandon 0 wantonness 0 unconstraint 0 002 @ 04885091 n 0000 + 01559270 a 0203 | the trait of lacking restraint or control; reckless freedom from inhibition or worry; "she danced with abandon"
//		04885091 07 n 01 unrestraint 0 006 @ 04884450 n 0000 ! 04882968 n 0101 ~ 04885271 n 0000 ~ 04885398 n 0000 ~ 04885609 n 0000 ~ 04885990 n 0000 | the quality of lacking restraint
	}
}
