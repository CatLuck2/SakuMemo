//
//  MemoModel.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/19.
//

import UIKit
import RealmSwift

class MemoModel: Object {
    @objc dynamic var id: Int = Int(arc4random_uniform(10000))
    @objc dynamic var title: String = ""
    @objc dynamic var sentence: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
