//
//  LLWordsControllerProtocol.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-14.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation

enum StudyWodrsType : Int {
	case all = 0
	case studying
	case studied
    
    var next: StudyWodrsType {
        switch self {
        case .all: return .studying
        case .studying: return .studied
        case .studied: return .all
        }
    }
    
    var localizedTitle: String {
        switch self {
        case .all: return NSLocalizedString("All", comment: "")
        case .studying: return NSLocalizedString("Studying", comment: "")
        case .studied: return NSLocalizedString("Studied", comment: "")
        }
    }
}

protocol LLSectionModelProtocol {
	var name:String {get}
	var count:Int {get}
}

@MainActor
protocol LLTableControllerProtocol {
	func load()
	func close()
}
