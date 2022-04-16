//
//  VocabularyRealm.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
final class VocabularyRealm: Object {
    dynamic var id: String?
    dynamic var episodeID: String?
    dynamic var word: String?
    dynamic var note: String?
    dynamic var updateDate: Date?

    override static func primaryKey() -> String {
        "id"
    }
}
