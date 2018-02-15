//
//  LHSQLManager.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-18.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHSQLManager: LHSQLBaseManager, LHSQLManagerProtocol {
	required override init(_ databaseUrl:URL) {
		super.init(databaseUrl)
	}
	
	required override init(_ databasePath:String) {
		super.init(databasePath)
	}
}
