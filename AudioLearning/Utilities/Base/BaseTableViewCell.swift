//
//  BaseTableViewCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/25.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUIColor()
    }
    
    func setupUIColor() {}
}
