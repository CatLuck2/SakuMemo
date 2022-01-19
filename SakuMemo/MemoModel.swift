//
//  MemoModel.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/19.
//

import UIKit
import RealmSwift

class MemoModel: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var sentence: String = ""
}
