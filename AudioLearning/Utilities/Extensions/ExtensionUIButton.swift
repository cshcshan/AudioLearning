//
//  ExtensionUIButton.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/15.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

extension UIButton {
    
    func circle(_ cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}
