//
//  IntentHandler.swift
//  MemoIntents
//
//  Created by Nekokichi on 2022/01/29.
//

import Intents

class IntentHandler: INExtension, ConfigurationIntentHandling {

    /*
     ”ウィジェットを編集”の選択肢として、MemoModel.texts()の各値を設定
     */
    func provideMemoTypeOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<MemoType>?, Error?) -> Void) {
        let memos: [MemoType] = MemoModel.texts().map { text in
            let memo = MemoType(identifier: text, display: text)

            return memo
        }

        let collection = INObjectCollection(items: memos)

        completion(collection, nil)
    }

    override func handler(for intent: INIntent) -> Any {

        return self
    }

}
