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
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundColor = highlighted ? Appearance.textColor : Appearance.backgroundColor
        titleLabel.backgroundColor = highlighted ? Appearance.textColor : Appearance.backgroundColor
        titleLabel.textColor = highlighted ? Appearance.backgroundColor : Appearance.textColor
        dateLabel.backgroundColor = highlighted ? Appearance.textColor : Appearance.backgroundColor
        dateLabel.textColor = highlighted ? Appearance.backgroundColor : Appearance.textColor
        descLabel.backgroundColor = highlighted ? Appearance.textColor : Appearance.backgroundColor
        descLabel.textColor = highlighted ? Appearance.backgroundColor : Appearance.textColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        backgroundColor = selected ? Appearance.textColor : Appearance.backgroundColor
        titleLabel.backgroundColor = selected ? Appearance.textColor : Appearance.backgroundColor
        titleLabel.textColor = selected ? Appearance.backgroundColor : Appearance.textColor
        dateLabel.backgroundColor = selected ? Appearance.textColor : Appearance.backgroundColor
        dateLabel.textColor = selected ? Appearance.backgroundColor : Appearance.textColor
        descLabel.backgroundColor = selected ? Appearance.textColor : Appearance.backgroundColor
        descLabel.textColor = selected ? Appearance.backgroundColor : Appearance.textColor
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
