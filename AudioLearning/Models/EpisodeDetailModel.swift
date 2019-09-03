//
//  EpisodeDetailModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/30.
//  Copyright © 2019 cshan. All rights reserved.
//

struct EpisodeDetailModel {
    var path: String?
    var scriptHtml: String?
    var audioLink: String?
    
    init(path: String?, scriptHtml: String?, audioLink: String?) {
        self.path = path
        self.scriptHtml = scriptHtml
        self.audioLink = audioLink
    }
}
