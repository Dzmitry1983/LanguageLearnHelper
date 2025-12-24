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
	
//	private var wordModel: LLSQLWordModel! = nil
	
//	var table: UITableView? = nil
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
    func updateFrom(_ wordModel:LLSQLWordModel, indexPath: IndexPath) {
//		self.wordModel = model
		
        self.wordLabel.text = "\(indexPath.row + 1): \(wordModel.word)"
//        self.wordLabel.text = wordModel.word
        self.speechLabel.text = wordModel.speech
        self.transcriptionLabel.text = wordModel.transcription
	}
}
