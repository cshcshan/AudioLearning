//
//  FlashCardCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class FlashCardCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    var vocabularyRealmModel: VocabularyRealmModel? {
        didSet {
            bindUI()
        }
    }
    
    private var isWordSide = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupUIColor()
    }
    
    func flip(isWordSide: Bool) {
        self.isWordSide = isWordSide
        contentView.backgroundColor = (isWordSide ? Appearance.backgroundColor : Appearance.textColor).withAlphaComponent(0.8)
        label.textColor = isWordSide ? Appearance.textColor : Appearance.backgroundColor
        label.text = isWordSide ? vocabularyRealmModel?.word : vocabularyRealmModel?.note
    }
    
    private func setupUIColor() {
        contentView.backgroundColor = Appearance.backgroundColor.withAlphaComponent(0.8)
        label.textColor = Appearance.textColor
    }
    
    private func setupUI() {
        let space: CGFloat = 20.0
        let side = UIScreen.main.bounds.width - (space * 2)
        let cornerRadius: CGFloat = 10.0
        let roundedRect = CGRect(origin: .zero, size: CGSize(width: side, height: side))

        // round-corner
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true

        // shadow
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 5
        self.layer.shadowPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius).cgPath
    }
    
    private func bindUI() {
        label.text = isWordSide ? vocabularyRealmModel?.word : vocabularyRealmModel?.note
    }
}
