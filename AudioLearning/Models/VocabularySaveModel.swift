//
//  VocabularySaveModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

struct VocabularySaveModel {
    var episode: String?
    var word: String?
    var note: String?
    
    init(episode: String?, word: String?, note: String?) {
        self.episode = episode
        self.word = word
        self.note = note
    }
}
