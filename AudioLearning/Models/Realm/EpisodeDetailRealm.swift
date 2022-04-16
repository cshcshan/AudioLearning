//
//  EpisodeDetailRealm.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/22.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
final class EpisodeDetailRealm: Object {
    dynamic var id: String?
    dynamic var path: String?
    dynamic var scriptHtml: String?
    dynamic var audioLink: String?

    override static func primaryKey() -> String {
        "id"
    }
}
