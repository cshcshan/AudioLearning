//
//  VocabularyCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class VocabularyCell: BaseTableViewCell {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    
    var vocabularyRealmModel: VocabularyRealmModel? {
        didSet {
            bindUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setupUIColor() {
        backgroundColor = Appearance.backgroundColor
        wordLabel.backgroundColor = Appearance.backgroundColor
        wordLabel.textColor = Appearance.textColor
        episodeLabel.backgroundColor = Appearance.backgroundColor
        episodeLabel.textColor = Appearance.textColor
    }
    
    private func bindUI() {
        wordLabel.text = vocabularyRealmModel?.word
        episodeLabel.text = vocabularyRealmModel?.episode
    }
}
