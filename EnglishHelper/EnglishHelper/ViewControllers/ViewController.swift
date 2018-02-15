//
//  ViewController.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-01-29.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	@IBOutlet var textView: NSTextView!
	
	var wordsModel = LHWordsModel()
	var lastLoadedUrl:URL?
	var prinstonDictionaryModel = LHPrinstonDictionaryModel()
	var sqlWordsManager:LHSQLWordsManager!
	var sqlStudyingManager:LHSQLStudyingManager!
	var sqlTestManager:LHSQLManagerProtocol!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
//		let test = "INSERT INTO `StudiedWords`(`id`,`word`,`speech`,`wordId`) VALUES (NULL,'',0,0);"
		
		
//		self.makeSQLDatabases()
		let filePathWords = "/Users/dzmitry.kudrashou/Documents/SQL/words.sqlite"
		let filePathStudying = "/Users/dzmitry.kudrashou/Documents/SQL/studying.sqlite"
		let sql = LHSQLWordsAndStudyManager(filePathWords)
		sql.attachDatabase(filePathStudying, databaseName: "std")
		let tableNames = sql.tables()
		var textArray = [String]()
		for table in tableNames {
			let count = sql.count(table.name)
			textArray.append("\(table.fullName) = \(count)")
			
		}
		textView.string = textArray.joined(separator: "\n")
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	private func makeSQLDatabases() {
		self.loadWordsModel()
		self.loadPringstonDictionry()
		
		let filePathWords = "file:///Users/dzmitry.kudrashou/Documents/SQL/words.sqlite"
		let filePathStudying = "file:///Users/dzmitry.kudrashou/Documents/SQL/studying.sqlite"
		self.sqlWordsManager = LHSQLWordsManager(filePathWords)
		self.sqlStudyingManager = LHSQLStudyingManager(filePathStudying)
		self.sqlWordsManager.clearAllTables()
		self.sqlStudyingManager.clearAllTables()
		
		var list = [LHSQLWordModel]()
		var studyingList = [LHSQLStudyingModel]()
		for model in self.prinstonDictionaryModel.results {
			let word = LHSQLWordModel()
			word.word = model.word//.replacingOccurrences(of: " ", with:"")
			word.speech = model.speechType
			for text in model.texts {
				let def = LHSQLDefinitionModel()
				def.definition = text
				word.definitions.append(def)
			}
			
			
			let key = LHDoubleDictionarysKey<LHTypeSpeech>(word.word, word.speech)
			if let wModel = self.wordsModel.wordsDictionary[key] {
				let studyingModel = LHSQLStudyingModel()
				studyingModel.word = wModel.word
				studyingModel.speech = wModel.speech
				studyingModel.studyType = .studying
				studyingList.append(studyingModel)
				
				for text in wModel.translated {
					let def = LHSQLTranslationModel()
					def.translation = text
					word.translations.append(def)
				}
				if word.transcription == nil && !wModel.transcription.isEmpty {
					word.transcription = wModel.transcription
				}
			}
			
			list.append(word)
		}
		self.sqlWordsManager.append(list)
		self.sqlStudyingManager.append(studyingList)
	}

	
	
	private func loadPringstonDictionry() {
		self.prinstonDictionaryModel.loadAll()
		
		
		
		var textArray = [String]()
		let values = self.prinstonDictionaryModel.results.filter { (model) -> Bool in
			return model.word.hasPrefix("a")
		}
		for model in values {
			let word = model.description
			
			textArray.append(word)
		}
		textView.string = textArray.joined(separator: "\n")
	}
	
	private func loadWordsModel() {
		let fileName = "new.json"
		if let path = Bundle.main.path(forResource:fileName, ofType:"") {
			print("Path is \(path)")
			if let url = URL(string:"file://\(path)") {
				self.loadFromJSON(url: url)
			}
		}
		else {
			print("Could not find path")
		}
	}
	
	private func updateTextField() {
		var textArray = [String]()
		let values = self.wordsModel.wordsDictionary.values.sorted { (lVal, rVal) -> Bool in
			return lVal < rVal
		}
		for model in values {
			let word = "\(model.word) \(model.transcription) (\(model.speech.rawValue))"
			let links = model.links.joined(separator:", ")
			let translates = model.translated.joined(separator:", ")
			textArray.append(word)
			textArray.append("(\(links))")
			textArray.append(translates)
			textArray.append("")
		}
		textView.string = textArray.joined(separator: "\n")
	}
	
	@IBAction func onClickSort(_ sender: NSButton) {
		let server = ServerControllerPromt()
		server.updateWordsModel(wordsModel: self.wordsModel, numberOfElements: 500)
		
//		textView.string = self.dictionaryModel.string
//		getTranslatedTexts(englishWord: "abandon")
	}
	
	@IBAction func onClickUpdate(_ sender: Any) {
		self.updateTextField()
	}
	
	
	private func openDictionary(url:URL) {
		self.lastLoadedUrl = url
		let ext = url.pathExtension
		switch ext {
		case "txt":
			self.loadFromFile(url:url)
		case "json":
			self.loadFromJSON(url:url)
		case "sqlite":
			self.loadFromSqlite(url:url)
		default:
			assert(true)
		}
	}
	
	private func loadFromSqlite(url:URL) {
		var textArray = [String]()
		if self.sqlTestManager == nil {
			self.sqlTestManager = LHSQLManager(url)
			self.sqlTestManager.detachDatabase("testDt2")
			self.sqlTestManager.attachDatabase("studying.sqlite", databaseName:"testDt2")
			
		}
		else {
			self.sqlTestManager.detachDatabase("testDt3")
			self.sqlTestManager.attachDatabase(url, databaseName:"testDt3")
		}
		
		let tableNames = self.sqlTestManager.tables()
		for table in tableNames {
			let count = self.sqlTestManager.count(table.name)
			textArray.append("\(table.fullName) = \(count)")
			
		}
		textView.string = textArray.joined(separator: "\n")
	}
	
	private func loadFromFile(url:URL) {
		self.wordsModel = LHFileLoader.list3000WordsLoad(url:url)
		self.updateTextField()
	}
	
	private func loadFromJSON(url:URL) {
		let test = LHJsonSerealization(url: url)
		if let model = test.loadModel() {
			self.wordsModel = model
			self.wordsModel.isChaned = false
			self.updateTextField()
		}
	}
	
	private func saveWordsModel(url:URL) {
		let test = LHJsonSerealization(url:url)
		self.wordsModel.isChaned = !test.saveModel(wordsModel: self.wordsModel)
	}
	
	@IBAction func openDocument(_ sender: Any) {
		let panel = NSOpenPanel.init()
		panel.allowsMultipleSelection = false
		panel.begin { (result) in
			if (result == NSFileHandlingPanelOKButton) {
				if let url = panel.url {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.openDictionary(url:url)
					}
					
				}
			}
		}
	}
	
	@IBAction func saveDocument(_ sender: Any){
		if let url = self.lastLoadedUrl {
			self.saveWordsModel(url: url)
		}
		
	}
	
	@IBAction func saveDocumentAs(_ sender: Any){
		let panel = NSSavePanel.init()
		//		panel.allowsMultipleSelection = false
		panel.begin { (result) in
			if (result == NSFileHandlingPanelOKButton) {
				if let url = panel.url {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.saveWordsModel(url: url)
					}
					
				}
			}
		}
	}
	
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		var returnValue = true
		if #selector(saveDocument) == menuItem.action {
			returnValue = self.wordsModel.wordsCount > 0 && (nil != self.lastLoadedUrl) && self.wordsModel.isChaned
		}
		if #selector(saveDocumentAs) == menuItem.action {
			returnValue = self.wordsModel.wordsDictionary.count > 0 && self.wordsModel.isChaned
		}
		return returnValue
	}
	
	
}

