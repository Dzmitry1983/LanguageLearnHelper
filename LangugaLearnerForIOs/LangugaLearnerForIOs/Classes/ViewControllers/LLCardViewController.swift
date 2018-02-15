//
//  LLCardViewController.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-07.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import UIKit

class LLCardViewController: UIViewController {

	private let duration:TimeInterval = 0.4
	
	@IBOutlet weak var flipView: UIView!
	@IBOutlet weak var originalWordView: UIView!
	@IBOutlet weak var descriptionView: UIView!
	
	@IBOutlet weak var wordLabel: UILabel!
	@IBOutlet weak var speechLabel: UILabel!
	@IBOutlet weak var transcriptionLabel: UILabel!
	@IBOutlet weak var otherFormsLabel: UILabel!
	
	@IBOutlet weak var descriptionTextView: UITextView!
	
	@IBOutlet weak var defToEnLabel: UILabel!
	@IBOutlet weak var enToDefLabel: UILabel!
	@IBOutlet weak var groupLabel: UILabel!
	@IBOutlet weak var filterLabel: UITextField!
	
	@IBOutlet weak var studyStatusSegmentController: UISegmentedControl!
	
	private var pageNumber:Int = 0
	private var wordModel:LLWordModelProtocol? = nil
	private var modelsArray:LLWordsControllerProtocol = LLSQLWordsController()
	var isIncrementedDef:Bool = false
	var isIncrementedEn:Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
//		self.wordModel = UserInfo.instance.nextWordForStudy()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.modelsArray.load()
		if self.wordModel == nil {
			self.wordModel = self.modelsArray.next()
		}
		self.updatePage()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.modelsArray.close()
	}
	
	private func updatePage() {
		self.originalWordView.isHidden = self.pageNumber != 0
		self.descriptionView.isHidden = self.pageNumber != 1
		
		self.wordLabel.text = ""
		self.speechLabel.text = ""
		self.transcriptionLabel.text = ""
		self.descriptionTextView.text = ""
		self.otherFormsLabel.text = ""
		self.groupLabel.text = ""
		
		if let model = self.wordModel {
			self.wordLabel.text = model.word
			self.speechLabel.text = model.speech
			self.transcriptionLabel.text = model.transcription
//			self.otherFormsLabel.text = model.links.joined(separator: ", ")
			self.descriptionTextView.text = model.definitions.joined(separator: "\n")
			self.defToEnLabel.text = "\(model.defToEnCount)"
			self.enToDefLabel.text = "\(model.enToDefCount)"
			self.studyStatusSegmentController.selectedSegmentIndex = model.studyingType
			
			self.groupLabel.text = model.studyingGroup
		}
		
	}
	
//	func alignTextVerticalInTextView(textView :UITextView) {
//		let size = textView.sizeThatFits(CGSizeMake(CGRectGetWidth(textView.bounds), CGFloat(MAXFLOAT)))
//		var topoffset = (textView.bounds.size.height - size.height * textView.zoomScale) / 2.0
//		topoffset = topoffset < 0.0 ? 0.0 : topoffset
//		textView.contentOffset = CGPointMake(0, -topoffset)
//	}
	
	private func addPageNumber() {
		self.pageNumber += 1
		if self.pageNumber > 1 {
			self.pageNumber = 0
			self.isIncrementedDef = false
			self.isIncrementedEn = false
			self.wordModel = self.modelsArray.next()
		}
	}
	
	private func subPageNumber() {
		self.pageNumber -= 1
		if self.pageNumber < 0 {
			self.pageNumber = 1
			self.isIncrementedDef = false
			self.isIncrementedEn = false
			self.wordModel = self.modelsArray.last()
		}
	}
	
	private func swipeToLeft() {
		self.addPageNumber()
		
		let animation = self.pageNumber == 0 ? UIViewAnimationOptions.transitionCurlUp : UIViewAnimationOptions.transitionFlipFromRight
		UIView.transition(with: self.flipView, duration:duration, options:animation, animations: {
			self.updatePage()
		}) { (isFinish) in
			
		}
		
		//transitionCurlUp
		//transitionCurlDown


	}
	
	private func swipeToRight() {
		self.subPageNumber()
		let animation = self.pageNumber == 1 ? UIViewAnimationOptions.transitionCurlDown : UIViewAnimationOptions.transitionFlipFromLeft
		UIView.transition(with: self.flipView, duration:duration, options:animation, animations: {
			self.updatePage()
		}) { (isFinish) in
			
		}
	}
	
	private func updateRepeateCounter() {
		switch self.pageNumber {
		case 0:
			if self.isIncrementedEn {
				self.wordModel?.defToEnCount -= 1
				
			}
			else {
				self.wordModel?.defToEnCount += 1
			}
			self.isIncrementedEn = !self.isIncrementedEn
		case 1:
			if self.isIncrementedDef {
				self.wordModel?.enToDefCount -= 1
			}
			else {
				self.wordModel?.enToDefCount += 1
			}
			self.isIncrementedDef = !self.isIncrementedDef
		default:
			assert(false)
		}
		self.updatePage()
		self.saveModel()
	}

	private func saveModel() {
		if let model = self.wordModel {
			self.modelsArray.saveModel(model)
		}
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	@IBAction func swipeSelector(_ sender: UISwipeGestureRecognizer) {
		switch sender.direction {
		case UISwipeGestureRecognizerDirection.left:
			self.swipeToLeft()
		case UISwipeGestureRecognizerDirection.right:
			self.swipeToRight()
		case UISwipeGestureRecognizerDirection.down:
			print(sender.direction)
		case UISwipeGestureRecognizerDirection.up:
			print(sender.direction)
		default:
			print("default")
		}
		print(sender)
	}
	
	@IBAction func tapGestureSelector(_ sender: UITapGestureRecognizer) {
		print(sender)
		self.updateRepeateCounter()
	}
	
	@IBAction func panGestureSelector(_ sender: UIPanGestureRecognizer) {
		//print(sender)
	}
	@IBAction func stadyChanged(_ sender: UISegmentedControl) {
		self.wordModel?.studyingType = sender.selectedSegmentIndex
		self.updatePage()
		self.saveModel()
	}

	@IBAction func filterChanged(_ textField: UITextField) {
		self.updateFilter(textField.text)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
	{
		if textField == self.filterLabel {
			self.updateFilter(textField.text)
		}
		
		textField.resignFirstResponder()
		return true
	}
	
	func updateFilter(_ newText:String?) {
		let text = newText == nil ? "" : newText!
		
		if text.compare(self.modelsArray.filterWord) != ComparisonResult.orderedSame {
			self.modelsArray.filterWord = text
			self.modelsArray.load()
			self.wordModel = self.modelsArray.next()
			self.updatePage()
		}
	}
}
