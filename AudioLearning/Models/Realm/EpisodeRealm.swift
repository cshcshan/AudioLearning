//
//  EpisodeRealm.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/20.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
final class EpisodeRealm: Object {
    dynamic var id: String?
    dynamic var title: String?
    dynamic var desc: String?
    dynamic var date: Date?
    dynamic var imagePath: String?
    dynamic var path: String?

    override static func primaryKey() -> String {
        "id"
    }
}
