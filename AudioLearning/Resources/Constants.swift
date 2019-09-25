//
//  Constants.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/25.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

enum AppearanceMode {
    case dark
    case light
}

struct Appearance {
    static let backgroundColor = appearanceMode == .dark ? Dark.backgroundColor : Light.backgroundColor
    static let textColor = appearanceMode == .dark ? Dark.textColor : Light.textColor
    
    private struct Dark {
        static let backgroundColor = UIColor(red: 22/255.0, green: 24/255.0, blue: 35/255.0, alpha: 1)
        static let textColor = UIColor.white
    }
    
    private  struct Light {
        static let backgroundColor = UIColor.white
        static let textColor = UIColor(red: 22/255.0, green: 24/255.0, blue: 35/255.0, alpha: 1)
    }
}

let appearanceMode = AppearanceMode.dark
