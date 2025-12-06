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
	var wordModel: LLWordModelProtocol?
	var modelsArray = LLSQLWordsTableControllerModel()
	
	@IBOutlet weak var studySegmentController: UISegmentedControl!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.modelsArray.load()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.modelsArray.close()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if let model = self.wordModel {
			self.textView.text = ""
			var stringArra = [String]()
			stringArra.append(model.word)
			stringArra.append(model.speech)
			for def in model.definitions {
				stringArra.append(def)
			}
			self.textView.text = stringArra.joined(separator: "\n")
			
			self.studySegmentController.selectedSegmentIndex = model.studyingType
		}
		
		
	}
    
	@IBAction func didStudyTypeChange(_ sender: UISegmentedControl) {
		self.wordModel?.studyingType = sender.selectedSegmentIndex
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

}
