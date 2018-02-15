//
//  ServerControllerPromt.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-01.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

class ServerControllerPromt: BaseServerController {
	
	let serverGetTranslateUrl = URL(string: "http://www.online-translator.com/services/TranslationService.asmx/GetTranslateNew")!
	let httpMethod = "POST"
	let session = URLSession()
//	let contentType = "application/json; charset=utf-8" //request.setValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
//	
	
	//let stringPost = "{ dirCode:'en-ru', template:'false', text:'" + englishWord + "', lang:'en', limit:3000,useAutoDetect:true, key:'', ts:'MainSite',tid:'',IsMobile:true}"
	
	func updateWordsModel(wordsModel:LHWordsModel, numberOfElements:UInt32) {
		var countForUpdate = numberOfElements
		
		let models = wordsModel.wordsDictionary.values.sorted { (wordModel1, wordModel2) -> Bool in
			return wordModel1 < wordModel2
		}
		var lastWord = ""
		for model in models {
			if lastWord == model.word {
				continue
			}
			lastWord = model.word
			if countForUpdate == 0 {
				break
			}
			if self.ifNeedToUpdate(wordModel: model) {
				countForUpdate -= 1
				self.update(wordForUpdate: model.word, wordsModel:wordsModel)
			}
		}
	}
	
	private func ifNeedToUpdate(wordModel:LHWordModel) -> Bool {
		return wordModel.translated.count == 0
	}
	
	private func update(wordForUpdate:String, wordsModel:LHWordsModel) {
		var request = URLRequest(url: self.serverGetTranslateUrl)
		request.httpMethod = httpMethod
		let word = wordForUpdate
//		let word = "document"
		let stringPost = "{ dirCode:'en-ru', template:'false', text:'" + word + "', lang:'en', limit:3000,useAutoDetect:true, key:'', ts:'MainSite',tid:'',IsMobile:true}"
		
		let data = stringPost.data(using: String.Encoding.utf8)
		request.timeoutInterval = 50
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
		request.httpBody = data
		request.httpShouldHandleCookies = false
		
		let session = URLSession.shared
		
//		let session = self.session
		let task = session.dataTask(with: request) { (data, response, error) in
			do {
				var dict1 = Dictionary<String, AnyObject>()
				if let jsonResult = try JSONSerialization.jsonObject(with: data!) as? Dictionary<String, AnyObject> {
						dict1 = jsonResult["d"] as! Dictionary<String, AnyObject>
				}
				
				var string = dict1["result"] as! String
				let isWord = dict1["isWord"] as! Bool
				if !isWord {
					return
				}
				
//				var resString = "<result>" + string1 + "</result>"
				string = string.replacingOccurrences(of: "&nbsp;", with: " ")
//				string = string.replacingOccurrences(of: "\n", with: "")
				string = string.replacingOccurrences(of: "\t", with: "")
				if string.contains("<dpan") {
					return
				}
//				let pattern = "<[^>]*>"// "\\[.+?\\]"
//				let pattern = "<[^>]*>"// "\\[.+?\\]"
//				let patterns = ["<style[^>]*>[^<]*</style>",
//				                "<[^>]*div[^>]*>",
//				                "<a [^>]*>[^<]*</a>",
//				                "<a [^>]*>",
//				                "<script[^>]*>[^<]*</script>",
//				                "<span style[^>]*>[^<]*</span>",
//				                "<img[^>]*>",
//				                "<wrs[^>]*>",
//				                "</wrs[^>]*>",
//				                "<li[^>]*>",
//				                "</li[^>]*>",
//				                "<ol[^>]*>",
//				                "</ol[^>]*>"]
				let patterns = ["<style[\\s\\S]*?</style>",
				                "<script[\\s\\S]*?</script>",
				                "<a[\\s\\S]*?</a>",
				                "<img[^>]*>",
				                "<div[^>]*>",
				                "<wrs[^>]*>",
				                "<li[^>]*>",
				                "<ol[^>]*>",
				                "</div>",
				                "</li>",
				                "</ol>",
				                "</wrs>",
				                "<span id=\\\"al_fullWR[\\s\\S]*?</span>",
				                "<span style[\\s\\S]*?</span></span>",
				                "<span class=\\\"loadFrv[\\s\\S]*?</span>",
				                "<span class=\\\"sforms_src[\\s\\S]*?</span>",
				                "<span class=\\\"ref_info[\\s\\S]*?</span>",
				                "<span class=\\\"pronunciation[^>]*>",
				                "<span class=\\\"ref_source[^>]*>",
				                "<span class=\\\"ref_dictionary[^>]*>",
				                "</span>",
								"\\B\\s{2,}",
					
								
								//				                "<span class=\"loadFrv[^>]*>[^<]*</span>",
					//				                "<span class=\"pronunciation[^>]*>[^<]*</span>",
					//				                ">\\s*[^<]",
					//				                "^\\s*[^<]",
					
					//                "</[^s][^>]*>"
				]
				
//				let patterns2 = ["<span c[^>]*>[^<]*</span>"
//				                ]
				//				let pattern = ">[^<]*<"// "\\[.+?\\]"
//				var str2 = ""
//				for patt in patterns2 {
//					str2 = self.substringForRegexp(string: string, pattern: patt)
//				}

				
				for patt in patterns {
					string = self.removeSubstringForRegexp(string: string, pattern: patt)
				}
				
				var parsededArray = Array<LHWordModel>()
				var array = string.components(separatedBy:"<span class=\"fsform_link\">")
				array = array.filter({ (string) -> Bool in
					
					return string.contains("<span")
				})
				for textString in array {
					if let wordModel = self.wordModelFromString(string: textString) {
						parsededArray.append(wordModel)
					}
					
				}
				if parsededArray.count == 0 {
					assert(false)
				}
				
				for model in parsededArray {
					model.word = word
					DispatchQueue.main.sync {
						wordsModel.add(model)
						print(model.description)
					}
					
//					wordModel.updateFrom(model)
				}
				
				print("Finish \(word)")
//
//				
//				var mass = string.components(separatedBy:"\n")
//
				
				
//
//				let regex = try NSRegularExpression.init(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
//				//var regex = NSRegularExpression(pattern:pattern, options: NSRegularExpression.Options.caseInsensitive, error: nil)
//				let nsString = string as NSString
//				let results = regex.matches(in: string, options: [], range: NSMakeRange(0, nsString.length))
//				var match = [String]()
//				for result in results {
//					for i in 0..<result.numberOfRanges {
//						let range = result.rangeAt(i)
//						match.append(nsString.substring( with: range))
//					}
//				}
//				
//
//				let data2 = resString.data(using: String.Encoding.utf8)
//				let parser = EnglishXMLParser()
//				parser.parse(data: data2!)
//				var ppp = parser.spanArray
//				print("ASynchronous\(str2)")
				
			}
			catch let error as Error {
				print(error.localizedDescription)
				assert(false)
			}
		}
		
		task.resume()
	}
	
	private func wordModelFromString(string:String) -> LHWordModel? {
		let arrayOfStrings = string.components(separatedBy:"<span class=\"").filter { (string) -> Bool in
			return !string.isEmpty
		}
		
		
		var keyValueArray = Array<(key:String, value:String)>()
		for text in arrayOfStrings {
			let arr = text.components(separatedBy:"\">")
			assert(arr.count == 2, "more")
			var value:(key:String, value:String)
			value.key = arr[0]
			value.value = arr[1]
			keyValueArray.append(value)
		}
		
		
		return wordModelFromKeyValueArray(array:keyValueArray)
	}
	
	private func wordModelFromKeyValueArray(array:Array<(key:String, value:String)>) -> LHWordModel? {
		var returnValue:LHWordModel? = nil
		var word:String?
		var speech:String?
		var transcription:String = ""
		var otherForms = [String]()
		var results = [String]()
		
		for value in array {
			switch value.key {
			case "source_only":
				word = self.getStringFromValue(string:value.value)
			case "ref_psp":
				speech = self.getStringFromValue(string:value.value)
			case "transcription":
				transcription = self.getStringFromValue(string:value.value)
			case "otherImportantForms":
				let array = self.getStringFromValue(string:value.value).components(separatedBy:"\n/")
				for str in array {
					let n = self.getStringFromValue(string:str)
					otherForms.append(n)
					
				}
				
			case "ref_result":
				results.append(self.getStringFromValue(string:value.value))
			default:
				assert(false)
			}
		}
		if word != nil {
			let speechType = self.speechTypeFrom(string:speech!)
			returnValue = LHWordModel(word:word!, speech:speechType)
			returnValue!.transcription = transcription
			returnValue!.translated = Set(results)
			returnValue!.links = Set(otherForms)
		}
		
		return returnValue
	}
	
	private func speechTypeFrom(string:String) -> LHTypeSpeech {
		var returnValue = LHTypeSpeech.Noun
		switch string {
		case "Verb":
			returnValue = .Verb
		case "":
			returnValue = .Unknown
		case "Noun":
			returnValue = .Noun
		case "Pronoun":
			returnValue = .Pronoun
		case "Adverb":
			returnValue = .Adverb
		case "Indefinite article":
			returnValue = .Indefinite
		case "Adjective":
			returnValue = .Adjective
		case "Preposition":
			returnValue = .Preposition
		case "Conjunction":
			returnValue = .Conjunction
		case "Quantitative",
		     "Determinative":
			returnValue = .Determiner
		case "Numeral":
			returnValue = .Number
			
		default:
			assert(false)
		}
		return returnValue
	}
	
	private func getStringFromValue(string:String) -> String {
		var returnValue = string
		
		let patterns = [
		                "^[\\s,-/]+",
		                "[\\s,-/]+$",
			]
		
		for patt in patterns {
			returnValue = self.removeSubstringForRegexp(string: returnValue, pattern: patt)
		}
		
		
		return returnValue
	}
	
	func removeSubstringForRegexp(string:String, pattern:String) -> String {
		var returnValue = string
		do {
			
			let regex = try NSRegularExpression.init(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
			let nsString = string as NSString
			let results = regex.matches(in: string, options: [], range: NSMakeRange(0, nsString.length))
			var match = [String]()
			var rangesForRemove = Array<NSRange>()
			for result in results {
				for i in 0..<result.numberOfRanges {
					let range = result.rangeAt(i)
					rangesForRemove.append(range)
					match.append(nsString.substring( with: range))
					
				}
			}
			rangesForRemove.sort(by: { (range1, range2) -> Bool in
				return range1.location > range2.location
			})
			
			var removeString = nsString
			
			for range in rangesForRemove {
				
				removeString = removeString.replacingCharacters(in:range, with:"") as NSString
				//				returnValue.removeSubrange(Range<String.Index>)
			}
			returnValue = removeString as String
//			for range in rangesForRemove {
//				
//				let start = returnValue.index(returnValue.startIndex, offsetBy: range.location)
//				let end = returnValue.index(returnValue.startIndex, offsetBy: range.location + range.length)
//				let myRange = start..<end
//
//				returnValue.removeSubrange(myRange)
////				returnValue.removeSubrange(Range<String.Index>)
//			}
			
		}
		catch {
			
		}
		return returnValue
	}
	
	func substringForRegexp(string:String, pattern:String) -> String {
		var returnValue = string
		do {
			
			let regex = try NSRegularExpression.init(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
			let nsString = string as NSString
			let results = regex.matches(in: string, options: [], range: NSMakeRange(0, nsString.length))
			var match = [String]()
			var rangesForRemove = Array<NSRange>()
			for result in results {
				for i in 0..<result.numberOfRanges {
					let range = result.rangeAt(i)
					rangesForRemove.append(range)
					match.append(nsString.substring( with: range))
					
				}
			}
			returnValue = match.joined()
			
		}
		catch {
			
		}
		return returnValue
	}
}

