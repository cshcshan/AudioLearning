//
//  Constants.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/25.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

enum AppearanceModeType: Int {
    case dark = 0
    case light
}

struct Appearance {
    private static var _mode: AppearanceModeType!
    static var mode: AppearanceModeType {
        get {
            if _mode == nil {
                _mode = UserDefaultManager.shared.appearanceMode
            }
            return _mode
        }
        set {
            _mode = newValue
            UserDefaultManager.shared.appearanceMode = newValue
        }
    }
    
    static var backgroundColor: UIColor {
        return mode == .dark ? Dark.backgroundColor : Light.backgroundColor
    }
    static var textColor: UIColor {
        return mode == .dark ? Dark.textColor : Light.textColor
    }
    
    private struct Dark {
        static let backgroundColor = UIColor(red: 22/255.0, green: 24/255.0, blue: 35/255.0, alpha: 1)
        static let textColor = UIColor.white
    }
    
    private struct Light {
        static let backgroundColor = UIColor.white
        static let textColor = UIColor(red: 22/255.0, green: 24/255.0, blue: 35/255.0, alpha: 1)
    }
}
