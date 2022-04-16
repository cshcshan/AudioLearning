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

enum Appearance {
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
        mode == .dark ? Dark.backgroundColor : Light.backgroundColor
    }

    static var secondaryBgColor: UIColor {
        mode == .dark ? Dark.secondaryBgColor : Light.secondaryBgColor
    }

    static var textColor: UIColor {
        mode == .dark ? Dark.textColor : Light.textColor
    }

    private enum Dark {
        static let backgroundColor = UIColor(rgb: (65, 75, 61))
        static let secondaryBgColor = UIColor(rgb: (7, 17, 14))
        static let textColor = UIColor(rgb: (250, 250, 250))
    }

    private enum Light {
        static let backgroundColor = UIColor(rgb: (250, 250, 250))
        static let secondaryBgColor = UIColor(rgb: (225, 225, 225))
        static let textColor = UIColor(rgb: (68, 68, 68))
    }
}
