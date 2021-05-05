//
//  EpisodeDetailRealmModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/22.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
final class EpisodeDetailRealmModel: Object {
    dynamic var episode: String?
    dynamic var path: String?
    dynamic var scriptHtml: String?
    dynamic var audioLink: String?
    
    override static func primaryKey() -> String {
        return "episode"
    }
}
