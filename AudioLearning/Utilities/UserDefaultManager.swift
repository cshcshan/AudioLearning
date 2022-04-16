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

    static let shared = UserDefaultManager()

    var appearanceMode: AppearanceModeType {
        get {
            guard let mode = userDefaults.object(forKey: UserDefaultKeys.appearance.rawValue) as? Int,
                  let appearanceMode = AppearanceModeType(rawValue: mode) else {
                return .dark
            }
            return appearanceMode
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: UserDefaultKeys.appearance.rawValue)
        }
    }

    private let userDefaults = UserDefaults.standard
}
