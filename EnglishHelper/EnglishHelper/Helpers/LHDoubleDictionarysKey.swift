//
//  LHDoubleDictionarysKey.swift
//  EnglishTableLerner
//
//  Created by Dzmitry Kudrashou on 2017-02-05.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

//import Cocoa
import Foundation

#if os(iOS)
	
#elseif os(OSX)
	
#endif

class LHDoubleDictionarysKey<CustomType: Equatable & Hashable> : Hashable {
	var firstKey:String
	var secondKey: CustomType
	
	init(firstKey:String, secondKey:CustomType) {
		self.firstKey = firstKey
		self.secondKey = secondKey
		
	}
	
	init(_ firstKey:String, _ secondKey:CustomType) {
		self.firstKey = firstKey
		self.secondKey = secondKey
		
	}
	
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.firstKey)
        hasher.combine(self.secondKey)
//        "\(self.firstKey) \(self.secondKey)".hashValue
    }
    
	//Equatable
	public static func ==(lhs: LHDoubleDictionarysKey, rhs: LHDoubleDictionarysKey) -> Bool {
		return lhs.firstKey == rhs.firstKey && lhs.secondKey == lhs.secondKey
	}
}
