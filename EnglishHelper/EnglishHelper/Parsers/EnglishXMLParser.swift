//
//  EnglishXMLParser.swift
//  EnglishHelper
//
//  Created by Dzmitry Kudrashou on 2017-01-30.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import Foundation


class EnglishXMLParser : NSObject, XMLParserDelegate {
	var xmlParser: XMLParser!
	var spanArray:[String] = []
	
	func parse(data:Data) {
		spanArray.removeAll()
		self.xmlParser = XMLParser(data:data)
		self.xmlParser.delegate = self
		self.xmlParser.parse()
	}
	
	func parser(_ parser: XMLParser,
	                     didStartElement elementName: String,
	                     namespaceURI: String?,
	                     qualifiedName qName: String?,
	                     attributes attributeDict: [String : String] = [:]) {
		let element = "<" + elementName + ">"
		
		
		print("<" + elementName)
		print(attributeDict)
		print(">")
//		if elementName == “item” {
//			weAreInsideAnItem = true
//		}
//		if weAreInsideAnItem {
//			switch elementName {
//			case “title”:
//				entryTitle = String()
//				currentParsedElement = “title”
//			case “itunes:summary”:
//				entryDescription = String()
//				currentParsedElement = “itunes:summary”
//			default: break
//			}
//		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
//  if weAreInsideAnItem {
//	switch currentParsedElement {
//	case “title”: {
//		entryTitle = entryTitle + string!
//		}
//	case “itunes:summary”: {
//		entryDescription = entryDescription + string!
//		}
//	default: break
//	}
		let element = string
		spanArray.append(element)
		print("element = \(string)")
	}
		
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		let element = "</" + elementName + ">"
		
		print(element)
//			if weAreInsideAnItem {
//				switch elementName {
//				case “title”: {
//					currentParsedElement = “”
//					}
//				case “itunes:summary”: {
//					currentParsedElement = “”
//					}
//    }
//    if elementName == “item” {
//		var entryPodcast = Podcast()
//		entryPodcast.podcastTitle = entryTitle
//		entryPodcast.podcastDescription = entryDescription
//		podcasts.append(entryPodcast)
//		weAreInsideAnItem = false
//    }
		}
	func parser(_ parser: XMLParser,
	            foundIgnorableWhitespace whitespaceString: String){
		print("foundIgnorableWhitespace\(whitespaceString)")
	}
	
	func parser(_ parser: XMLParser,
	            foundCDATA CDATABlock: Data){
		print("foundCDATA\(CDATABlock)")
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {
//  dispatch_async(dispatch_get_main_queue(), { () -> Void in
//	self.tableView.reloadData()
//})
		print("parserDidEndDocument")
//		self.xmlParser = nil
	}
	
	func parserDidStartDocument(_ parser: XMLParser) {
		print("parserDidStartDocument")
	}
	
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		print("parseError = \(parseError)")
	}
	
}


