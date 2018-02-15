//
//  LHSQLStudyingManager.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-17.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class LHSQLStudyingManager: LHSQLBaseManager, LHSQLManagerProtocol {
	
	required override init(_ databaseUrl:URL) {
		super.init(databaseUrl)
	}
	
	required override init(_ databasePath:String) {
		super.init(databasePath)
	}
	
	//MARK:- constant properties
	private let createFields:[String:String] = [
		LHSQLStudyingModel.table:LHSQLStudyingModel.sqlCreateTable,//"'id' INTEGER PRIMARY KEY AUTOINCREMENT, 'word' TEXT NOT NULL, 'speech' INTEGER NOT NULL",
		]
	
	
	
	//MARK:- overrided public methods
	override func createFieldsCommands() -> [String:String] {
		return self.createFields
	}
	
	override func open(url:URL) {
		super.open(url: url)
		if let db = self.sqlDataBase {
			let commands = self.createFieldsCommands()
			for info in commands {
				self.createTable(info.key, keys:info.value, dataBase: db)
			}
		}
	}
}
