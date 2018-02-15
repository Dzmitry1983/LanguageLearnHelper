//
//  LHSQLTable.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-19.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHSQLTable<Type>: LHSQLBaseTable, LHSQLTableProtocol {
	typealias Model = Type
	var count: Int {
		return rows.count
	}
	var rows = [Model]()
	subscript(index:Int) -> Model {
		return self.rows[index]
	}
	func append(_ newElement:Model) {
		self.rows.append(newElement)
	}
}
