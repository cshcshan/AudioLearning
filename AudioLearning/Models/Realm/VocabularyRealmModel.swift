//
//  VocabularyRealmModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class VocabularyRealmModel: Object {
    dynamic var episode: String?
    dynamic var word: String?
    dynamic var note: String?
    dynamic var updateDate: Date?
    
    override static func primaryKey() -> String {
        return "word"
    }
}
