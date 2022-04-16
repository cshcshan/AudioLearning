//
//  AlertModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/2.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation

struct AlertModel {
    let title: String?
    let message: String?

    init(title: String?, message: String?) {
        self.title = title
        self.message = message
    }
}

// MARK: - Equatable

extension AlertModel: Equatable {}
