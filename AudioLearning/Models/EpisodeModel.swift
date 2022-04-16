//
//  EpisodeModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation

struct EpisodeModel {
    var id: String?
    var title: String?
    var desc: String?
    var date: Date?
    var imagePath: String?
    var path: String?

    init(
        id: String? = nil,
        title: String? = nil,
        desc: String? = nil,
        date: Date? = nil,
        imagePath: String? = nil,
        path: String? = nil
    ) {
        self.id = id
        self.title = title
        self.desc = desc
        self.date = date
        self.imagePath = imagePath
        self.path = path
    }

    init(from episodeRealm: EpisodeRealm?) {
        self.id = episodeRealm?.id
        self.title = episodeRealm?.title
        self.desc = episodeRealm?.desc
        self.date = episodeRealm?.date
        self.imagePath = episodeRealm?.imagePath
        self.path = episodeRealm?.path
    }
}

// MARK: - Equatable

extension EpisodeModel: Equatable {}
