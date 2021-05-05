//
//  UserDefaultManager.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/5.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation

enum UserDefaultKeys: String {
    case appearance
}

protocol UserDefaultsManagerProtocol {
    var appearanceMode: AppearanceModeType { get set }
}

final class UserDefaultManager: UserDefaultsManagerProtocol {
    
    static let shared: UserDefaultManager = UserDefaultManager()
    
    var appearanceMode: AppearanceModeType {
        get {
            guard let mode = UserDefaults.standard.object(forKey: UserDefaultKeys.appearance.rawValue) as? Int else {
                self.appearanceMode = .dark
                return .dark
            }
            guard let appearanceMode = AppearanceModeType(rawValue: mode) else {
                self.appearanceMode = .dark
                return .dark
            }
            return appearanceMode
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultKeys.appearance.rawValue)
        }
    }
}
