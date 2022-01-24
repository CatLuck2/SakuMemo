//
//  MemoListTableViewCell.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/19.
//

import UIKit

class MemoListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sentenceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMemoDatasToCell(sentence: NSMutableAttributedString) {
        sentenceLabel.attributedText = sentence
    }
    
}
