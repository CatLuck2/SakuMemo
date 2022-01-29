//
//  IntentHandler.swift
//  MemoIntents
//
//  Created by Nekokichi on 2022/01/29.
//

import Intents


class IntentHandler: INExtension, ConfigurationIntentHandling  {
    
    func provideMemoTypeOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<MemoType>?, Error?) -> Void) {
        
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
