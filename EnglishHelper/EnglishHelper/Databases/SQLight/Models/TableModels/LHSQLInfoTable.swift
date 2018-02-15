//
//  LHSQLInfoTable.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-19.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation



class LHSQLInfoTable : LHSQLTableInfoProtocol, CustomStringConvertible {
	internal var filter: LHSQLTableFilterProtocol?

	var database:String? = nil
	var name:String
	var count:Int = 0
	var fields:[String] = [String]()
	
	var fullName:String {
		if self.database == nil {
			return self.name
		}
		else {
			return "\(self.database!).\(self.name)"
		}
	}
	
	init(_ name:String) {
		self.name = name
	}
	
	var description: String {
		return self.fullName
	}
}
