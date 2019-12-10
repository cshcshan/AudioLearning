//
//  ExtensionFileManager.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/20.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation

extension FileManager {
    var documentURL: URL? {
        return self.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
