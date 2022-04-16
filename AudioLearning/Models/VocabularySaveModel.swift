//
//  VocabularySaveModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

struct VocabularySaveModel {
    let word: String?
    let note: String?

    init(word: String?, note: String?) {
        self.word = word
        self.note = note
    }
}
