//
//  LHIndexSenseModel.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-02-08.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

//enum LHTypeSynset : String {
//	case Unknown
//	case Noun
//	case Verb
//	case Adjective
//	case Adverb
//}

class LHIndexSenseModel : LHBasePrinstonModel{
	private(set) var word:String = ""
	private(set) var address:String = ""
	private(set) var synsetType:LHTypeSpeech = .Unknown
	private(set) var magicWord:String = ""
	private(set) var lexicographerNumber:Int = 0 //Lexicographer Files
	private(set) var magicNumber3:Int = 0
	private(set) var magicNumber4:Int = 0
	private(set) var magicNumber5:Int = 0
	private(set) var magicNumber6:Int = 0
	
	
	override func parseLine(line:String) {
		//pontifical%5:00:00:pretentious:00 01849960 3 0
		//abamp%1:23:00:: 13637722 1 0
		var array:Array<String> = line.components(separatedBy:"%")
//		Scanner.
		assert(array.count == 2)
		self.word = array[0].replacingOccurrences(of:"_", with:" ")
		var newLine = array[1]
		array = newLine.components(separatedBy:" ")
		assert(array.count == 4)
//		head_id
		self.address = array[1]
		self.magicNumber5 = Int(array[2])!
		self.magicNumber6 = Int(array[3])!
		newLine = array[0]
		array = newLine.components(separatedBy:":")
		assert(array.count == 5)
		//ss_type
		if !array[0].isEmpty {
			self.synsetType = self.updateSpeechType(number:Int(array[0])!)
		}
		//lex_filenum
		if !array[1].isEmpty {
			self.lexicographerNumber = Int(array[1])!
		}
		//lex_id
		if !array[2].isEmpty {
			self.magicNumber3 = Int(array[2])!
		}
		//head_word
		if !array[4].isEmpty {
			self.magicNumber4 = Int(array[4])!
		}
		assert(self.synsetType != .Unknown)
	
		self.magicWord = array[3]
	}
	
	private func updateSpeechType(number:Int) -> LHTypeSpeech {
		var returnValue:LHTypeSpeech = .Unknown
		switch number {
		case 1:
			returnValue = .Noun
		case 2:
			returnValue = .Verb
		case 3:
			returnValue = .Adjective
		case 4:
			returnValue = .Adverb
		case 5:
			returnValue = .Adjective
		default:
			returnValue = .Unknown
		}
		return returnValue
	}
	
	static let lexicographerDictionary:Dictionary<Int, String> = [
		00:"all adjective clusters",
		01:"relational adjectives (pertainyms)",
		02:"all adverbs",
		03:"unique beginner for nouns",
		04:"nouns denoting acts or actions",
		05:"nouns denoting animals",
		06:"nouns denoting man-made objects",
		07:"nouns denoting attributes of people and objects",
		08:"nouns denoting body parts",
		09:"nouns denoting cognitive processes and contents",
		10:"nouns denoting communicative processes and contents",
		11:"nouns denoting natural events",
		12:"nouns denoting feelings and emotions",
		13:"nouns denoting foods and drinks",
		14:"nouns denoting groupings of people or objects",
		15:"nouns denoting spatial position",
		16:"nouns denoting goals",
		17:"nouns denoting natural objects (not man-made)",
		18:"nouns denoting people",
		19:"nouns denoting natural phenomena",
		20:"nouns denoting plants",
		21:"nouns denoting possession and transfer of possession",
		22:"nouns denoting natural processes",
		23:"nouns denoting quantities and units of measure",
		24:"nouns denoting relations between people or things or ideas",
		25:"nouns denoting two and three dimensional shapes",
		26:"nouns denoting stable states of affairs",
		27:"nouns denoting substances",
		28:"nouns denoting time and temporal relations",
		29:"verbs of grooming, dressing and bodily care",
		30:"verbs of size, temperature change, intensifying, etc.",
		31:"verbs of thinking, judging, analyzing, doubting",
		32:"verbs of telling, asking, ordering, singing",
		33:"verbs of fighting, athletic activities",
		34:"verbs of eating and drinking",
		35:"verbs of touching, hitting, tying, digging",
		36:"verbs of sewing, baking, painting, performing",
		37:"verbs of feeling",
		38:"verbs of walking, flying, swimming",
		39:"verbs of seeing, hearing, feeling",
		40:"verbs of buying, selling, owning",
		41:"verbs of political and social activities and events",
		42:"verbs of being, having, spatial relations",
		43:"verbs of raining, snowing, thawing, thundering",
		44:"participial adjectives",
	]
}

//pontifical%5:00:00:pretentious:00 01849960 3 0

/*
File Number	Name	Contents
00	adj.all	all adjective clusters
01	adj.pert	relational adjectives (pertainyms)
02	adv.all	all adverbs
03	noun.Tops	unique beginner for nouns
	04	noun.act	nouns denoting acts or actions
05	noun.animal	nouns denoting animals
06	noun.artifact	nouns denoting man-made objects
07	noun.attribute	nouns denoting attributes of people and objects
08	noun.body	nouns denoting body parts
09	noun.cognition	nouns denoting cognitive processes and contents
10	noun.communication	nouns denoting communicative processes and contents
11	noun.event	nouns denoting natural events
12	noun.feeling	nouns denoting feelings and emotions
13	noun.food	nouns denoting foods and drinks
14	noun.group	nouns denoting groupings of people or objects
15	noun.location	nouns denoting spatial position
16	noun.motive	nouns denoting goals
17	noun.object	nouns denoting natural objects (not man-made)
18	noun.person	nouns denoting people
19	noun.phenomenon	nouns denoting natural phenomena
20	noun.plant	nouns denoting plants
21	noun.possession	nouns denoting possession and transfer of possession
22	noun.process	nouns denoting natural processes
23	noun.quantity	nouns denoting quantities and units of measure
24	noun.relation	nouns denoting relations between people or things or ideas
25	noun.shape	nouns denoting two and three dimensional shapes
26	noun.state	nouns denoting stable states of affairs
27	noun.substance	nouns denoting substances
28	noun.time	nouns denoting time and temporal relations
29	verb.body	verbs of grooming, dressing and bodily care
30	verb.change	verbs of size, temperature change, intensifying, etc.
31	verb.cognition	verbs of thinking, judging, analyzing, doubting
32	verb.communication	verbs of telling, asking, ordering, singing
33	verb.competition	verbs of fighting, athletic activities
34	verb.consumption	verbs of eating and drinking
35	verb.contact	verbs of touching, hitting, tying, digging
36	verb.creation	verbs of sewing, baking, painting, performing
37	verb.emotion	verbs of feeling
38	verb.motion	verbs of walking, flying, swimming
39	verb.perception	verbs of seeing, hearing, feeling
40	verb.possession	verbs of buying, selling, owning
41	verb.social	verbs of political and social activities and events
42	verb.stative	verbs of being, having, spatial relations
43	verb.weather	verbs of raining, snowing, thawing, thundering
44	adj.ppl	participial adjectives
*/
