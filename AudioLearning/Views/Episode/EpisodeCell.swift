//
//  EpisodeCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class EpisodeCell: BaseTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var episodeModel: EpisodeModel? {
        didSet {
            bindUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setupUIColor() {
        backgroundColor = Appearance.backgroundColor
        titleLabel.backgroundColor = Appearance.backgroundColor
        titleLabel.textColor = Appearance.textColor
        dateLabel.backgroundColor = Appearance.backgroundColor
        dateLabel.textColor = Appearance.textColor
        descLabel.backgroundColor = Appearance.backgroundColor
        descLabel.textColor = Appearance.textColor
    }
    
    private func bindUI() {
        titleLabel?.text = episodeModel?.title
        dateLabel?.text = episodeModel?.date?.toString(dateFormat: "yyyy/M/d")
        descLabel?.text = episodeModel?.desc
    }
}
