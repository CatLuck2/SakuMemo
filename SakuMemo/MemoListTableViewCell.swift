//
//  MemoListTableViewCell.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/19.
//

import UIKit

class MemoListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sentenceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setMemoDatasToCell(title: String, sentence: NSMutableAttributedString) {
        titleLabel.text = title
        sentenceLabel.attributedText = sentence
    }
    
}
