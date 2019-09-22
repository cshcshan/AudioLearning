//
//  ExtensionFileManager.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/20.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation

extension FileManager {
    
    func documentURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
