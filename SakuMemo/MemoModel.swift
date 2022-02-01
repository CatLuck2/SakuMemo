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
    @objc dynamic var sentence: Data = Data()

    override static func primaryKey() -> String? {
        return "id"
    }
}

struct SharedRealmModel {
    static var memoListDatas: Results<MemoModel>!
}

extension MemoModel {
    static var realm: Realm? {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Nekokichi.WidgetWithRealm")!
        let realmURL = container.appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        do {
            let realmResult = try Realm(configuration: config)
            return realmResult
        } catch let error as NSError {
            print(error)
            return nil
        }
    }

    static func all() -> Results<MemoModel> {
        realm!.objects(self)
    }

    static func texts() -> [String] {
        var arrays: [String] = []
        for index in 0..<all().count {
            do {
                let data = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSMutableAttributedString.self, from: all()[index].sentence)! as NSMutableAttributedString
                arrays.append(data.string)
            } catch let error as NSError {
                print(error)
            }
        }
        return arrays
    }
}
