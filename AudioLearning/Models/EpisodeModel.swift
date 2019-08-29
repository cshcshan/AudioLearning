//
//  EpisodeModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation

struct EpisodeModel {
    var episode: String?
    var title: String?
    var desc: String?
    var date: Date?
    var imagePath: String?
    
    init(episode: String?, title: String?, desc: String?, date: Date?, imagePath: String?) {
        self.episode = episode
        self.title = title
        self.desc = desc
        self.date = date
        self.imagePath = imagePath
    }
}
