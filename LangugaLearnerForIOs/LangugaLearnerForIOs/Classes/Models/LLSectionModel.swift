//
//  LLSectionModel.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-14.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import UIKit

class LLSectionModel: LLBaseModel, LLSectionModelProtocol {
	var name:String = "" //{get}
	var count:Int = 0 // {get}
	
	init(name:String, count:Int) {
		self.name = name
		self.count = count
	}

}
