//
//  LLDefenitionViewController.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-13.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import UIKit

class LLDefenitionViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!
	var wordModel: LLSQLWordModel?
	var modelsArray = LLSQLWordsTableControllerModel()
	
	@IBOutlet weak var studySegmentController: UISegmentedControl!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.modelsArray.load()
        
        self.updateView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
        self.updateView()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.modelsArray.close()
    }
    
	@IBAction func didStudyTypeChange(_ sender: UISegmentedControl) {
		self.wordModel?.studyingType = sender.selectedSegmentIndex
		self.saveModel()
	}
    
    private func updateView() {
        if let model = self.wordModel {
            self.textView.text = """
                \(model.word)
                \(model.speech)
                
                \(model.definitions.joined(separator: "\n"))
                """
            
            self.studySegmentController.selectedSegmentIndex = model.studyingType
        }
    }
	
	private func saveModel() {
		if let model = self.wordModel {
			self.modelsArray.saveModel(model)
		}
		
	}
}
