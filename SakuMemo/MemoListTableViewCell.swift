//
//  MemoListTableViewCell.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/19.
//

import UIKit

final class MemoListTableViewCell: UITableViewCell {

    @IBOutlet weak private var sentenceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    /*
     セルのラベルに値を代入
     セルの処理を当ファイルで完結するため
     */
    func setMemoDatasToCell(sentence: NSMutableAttributedString) {
        sentenceLabel.attributedText = sentence
    }
}

extension MemoListTableViewCell {
    enum Identifier: String {
        case nibName = "MemoListTableViewCell"
        case forCellReuseIdentifier = "MemoListTableViewCellID"
    }
}
