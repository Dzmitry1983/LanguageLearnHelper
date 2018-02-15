//
//  LHSQLTableWordsAndStudy.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-19.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHSQLTableWordsAndStudy: LHSQLBaseTable, LHSQLTableProtocol {
	typealias Model = (words:LHSQLWordModel, study:LHSQLStudyingModel)
	var rows = [Model]()
	var database:String? = nil
	var name:String = ""
	var fields:[String] = [""]
	var count: Int {
		return rows.count
	}
	subscript(index:Int) -> Model {
		return self.rows[index]
	}
	func append(_ newElement:Model) {
		self.rows.append(newElement)
	}
}
