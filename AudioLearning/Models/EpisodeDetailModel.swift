//
//  EpisodeDetailModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/30.
//  Copyright © 2019 cshan. All rights reserved.
//

struct EpisodeDetailModel {
    var link: String?
    var scriptHtml: String?
    var audioLink: String?
    
    init(link: String?, scriptHtml: String?, audioLink: String?) {
        self.link = link
        self.scriptHtml = scriptHtml
        self.audioLink = audioLink
    }
}
