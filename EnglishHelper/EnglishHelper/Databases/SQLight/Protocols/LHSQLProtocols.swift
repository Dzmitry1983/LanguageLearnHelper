//
//  LHSQLProtocols.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-20.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

enum LHSQLTableFieldType {
	case text
	case numeric
	case integer
	case real
	case blob
}

enum LHSQLComparisonExpression {
	case like
//	", "==", "<", "<=", ">", ">=", "!=", "", "IN", "NOT IN", "BETWEEN", "IS", and "IS NOT", .
}

//Comparison Expressions
//SQLite version 3 has the usual set of SQL comparison operators including "=", "==", "<", "<=", ">", ">=", "!=", "", "IN", "NOT IN", "BETWEEN", "IS", and "IS NOT", .


//static var sqlCreateTable:String = "`id` INTEGER PRIMARY KEY AUTOINCREMENT, `word` TEXT NOT NULL, `transcription` TEXT, `speech` INTEGER NOT NULL"


protocol LHSQLManagerProtocol {
	init(_ databaseUrl:URL)
	init(_ databasePath:String)
	func open(url:URL)
	func close()
	
	func attachDatabase(_ databaseUrl:URL, databaseName:String)
	func attachDatabase(_ databasePath:String, databaseName:String)
	func detachDatabase(_ databaseName:String)
	
	func clearAllTables()
	func tables() -> [LHSQLTableInfoProtocol]
	//	func tables<T:LHSQLTableProtocol>() -> [T]
	func count(_ table:String) -> Int64
	func append<Type:SQLModelProtocol>(_ models:[Type])
//	func select<Type:LHSQLTableProtocol>(_ table:Type, filter:String?) -> Type
	
	
	//	func modelsd<Type:SQLModelProtocol>(_ models:[Type])
	
	//
	//	func dissapendDatabase()
	
	//	func remove()
	//	func update()
	
}

protocol LHSQLTableInfoProtocol {
	var database:String? {get set}
	var name:String {get set}
	var fullName:String {get}
	var count:Int {get set}
	var fields:[String] {get set}
}

protocol LHSQLTableFieldInfoProtocol {
	var fieldName:String {get set}
	var fieldType:LHSQLTableFieldType {get set}
}

protocol LHSQLTableFilterProtocol {
//	var leftField:LHSQLTableFieldInfoProtocol {get set}
//	var rightField:LHSQLTableFieldInfoProtocol {get set}
//	var comparisonExpression:LHSQLComparisonExpression {get set}
	var value:Any? {get set}
}

protocol LHSQLTableProtocol/*: RandomAccessCollection, MutableCollection */ {
	associatedtype Model
	var rows:[Model] {get}
	var count: Int {get}
	//	var sqlCreateTable:String {get}
	//	var sqlFields:[String] {get}
	func append(_ newElement:Model)
	subscript(index:Int) -> Model { get }
	
}

protocol SQLModelProtocol {
	var id:Int32 {get set}
	static var sqlCreateTable:String {get}
	static var sqlFields:[String] {get}
	static var table:String {get}
	subscript(index: String) -> Any { get }
	
}

