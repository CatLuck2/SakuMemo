//
//  IntentHandler.swift
//  MemoIntents
//
//  Created by Nekokichi on 2022/01/29.
//

import Intents


class IntentHandler: INExtension, ConfigurationIntentHandling  {
    
    func provideMemoTypeOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<MemoType>?, Error?) -> Void) {
        
        var memoCollection: [String] = []
        for index in 0...SharedRealmModel.memoListDatas.count {
            do {
                let data = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSMutableAttributedString.self, from: SharedRealmModel.memoListDatas[index].sentence)
                let sentence = data! as NSMutableAttributedString
                memoCollection.append(sentence.string)
            } catch let error as NSError {
                print(error)
            }
        }
        
        let memos: [MemoType] = memoCollection.map { coffee in
            let memo = MemoType(identifier: coffee, display: coffee)
            
            return memo
        }
        
        let collection = INObjectCollection(items: memos)
        
        completion(collection, nil)
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
