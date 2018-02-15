//
//  LLWordStudyTableViewCell.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-21.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import UIKit

class LLWordStudyTableViewCell: UITableViewCell {

	@IBOutlet weak var wordLabel: UILabel!
	@IBOutlet weak var speechLabel: UILabel!
	@IBOutlet weak var transcriptionLabel: UILabel!
	
	private var wordModel:LLWordModelProtocol! = nil
	
	var table:UITableView? = nil
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func updateFrom(_ model:LLWordModelProtocol) {
		self.wordModel = model
		self.update()
	}
	
	private func update() {
		self.wordLabel.text = self.wordModel.word
		self.speechLabel.text = self.wordModel.speech
		self.transcriptionLabel.text = self.wordModel.transcription
		
	}
}
