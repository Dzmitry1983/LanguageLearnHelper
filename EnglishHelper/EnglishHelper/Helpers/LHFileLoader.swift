//
//  LHFileLoader.swift
//  EnglishTableLerner
//
//  Created by Dzmitry Kudrashou on 2017-02-06.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation


class LHFileLoader {
	
	static func list3000WordsLoad(url:URL) -> LHWordsModel {
		
		
		let sppechDictionary:[String:LHTypeSpeech] = [
			" adj":.Adjective,
			" adv":.Adverb,
			" pron":.Pronoun,
			" conj":.Conjunction,
			" modal":.Verb,
			" prep":.Preposition,
			" interjection":.Interjection,
			" indefinite":.Indefinite,
			" article":.Article,
			" determiner":.Determiner,
			" predeterminer":.Predeterminer,
			" v":.Verb,
			" n":.Noun]
		
		/*
		enum TypeSpeech {
		case TypeSpeechNoun
		case TypeSpeechPronoun
		case TypeSpeechVerb
		case TypeSpeechAdjective
		case TypeSpeechAdverb
		case TypeSpeechPreposition
		case TypeSpeechConjunction
		case TypeSpeechInterjection
		case TypeSpeechArticle
		
		}
		*/
		let returnValue = LHWordsModel()
		let stringText:String?
		do {
			stringText = try String.init(contentsOf:url)
		}
		catch {
			stringText = nil
		}
		
		if let fileText = stringText {
			let array = fileText.components(separatedBy:"\n")
			for line in array {
				var word = line
				var speeches = Array<LHTypeSpeech>()
				for wordForRemove in sppechDictionary.keys {
					if let range = word.range(of: wordForRemove) {
						word.removeSubrange(range)
						if let speech = sppechDictionary[wordForRemove] {
							speeches.append(speech)
						}
					}
				}
				for speech in speeches {
					let wordModel = LHWordModel(word: word, speech:speech)
					returnValue.add(wordModel)
				}
				
			}
		}
		return returnValue
	}
	
	
	private static func testLoad() {
		let testText = ""
		
		let removeElements:[String] = ["",
		                               " ",
		                               "  ",
		                               "   ",
		                               "    ",
		                               "     ",
		                               "      ",
		                               "       "]
		
		
		var text = testText.replacingOccurrences(of:"\n", with:" ")
		text = text.replacingOccurrences(of:"\t", with:"")
		text = text.replacingOccurrences(of:"pron,", with:" pron, ")
		text = text.replacingOccurrences(of:",", with:" ")
		text = text.replacingOccurrences(of:"W2", with:"W1")
		text = text.replacingOccurrences(of:"W3", with:"W1")
		text = text.replacingOccurrences(of:"S1", with:"W1")
		text = text.replacingOccurrences(of:"S2", with:"W1")
		text = text.replacingOccurrences(of:"S3", with:"W1")
		text = text.replacingOccurrences(of:"adjW1", with:" adj W1")
		text = text.replacingOccurrences(of:"advW1", with:" adv W1")
		text = text.replacingOccurrences(of:"conjW1", with:" conj W1")
		text = text.replacingOccurrences(of:"pronW1", with:" pron W1")
		text = text.replacingOccurrences(of:"nW1", with:" n W1")
		text = text.replacingOccurrences(of:"vW1", with:" v W1")
		text = text.replacingOccurrences(of:"     ", with:" ")
		text = text.replacingOccurrences(of:"    ", with:" ")
		text = text.replacingOccurrences(of:"   ", with:" ")
		text = text.replacingOccurrences(of:"  ", with:" ")
		text = text.replacingOccurrences(of:" W1", with:"W1")
		text = text.replacingOccurrences(of:"W1 ", with:"W1")
		text = text.replacingOccurrences(of:"W1", with:"\n")
		var array = text.components(separatedBy:"\n")
		
		//		array = array?.sorted()
		array = array.filter({ (element) -> Bool in
			var returnValue:Bool = false
			returnValue = !removeElements.contains(element)
			return returnValue
		})
		
		text = array.joined(separator: "\n")
		//		text = text?.replacingOccurrences(of:"\t", with:"")
		print(text)
	}
}
