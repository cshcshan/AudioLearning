//
//  EpisodeDetail.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/30.
//  Copyright © 2019 cshan. All rights reserved.
//

struct EpisodeDetail {
    let scriptHtml: String?
    let audioLink: String?

    init(scriptHtml: String?, audioLink: String?) {
        self.scriptHtml = scriptHtml
        self.audioLink = audioLink
    }
}
