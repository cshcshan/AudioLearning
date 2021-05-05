//
//  FlashCardCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift

final class FlashCardCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    var vocabularyRealmModel: VocabularyRealmModel? {
        didSet {
            bindUI()
        }
    }
    
    private var isWordSide = true
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupNotification()
        setupUI()
    }
    
    private func setupNotification() {
        NotificationCenter.default.rx
            .notification(.changeAppearance)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.flip(self.isWordSide)
            })
            .disposed(by: disposeBag)
    }
    
    func flip(_ isWordSide: Bool) {
        self.isWordSide = isWordSide
        contentView.backgroundColor = (isWordSide ? Appearance.backgroundColor : Appearance.textColor)
        label.textColor = isWordSide ? Appearance.textColor : Appearance.backgroundColor
        label.text = isWordSide ? vocabularyRealmModel?.word : vocabularyRealmModel?.note
    }
    
    private func setupUI() {
        let space: CGFloat = 20.0
        let width = UIScreen.main.bounds.width - (space * 2)
        let height = width * 0.6 // 3:5
        let cornerRadius: CGFloat = 10.0
        let roundedRect = CGRect(origin: .zero, size: CGSize(width: width, height: height))

        // round-corner
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true

        // shadow
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: -3, height: 3)
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius).cgPath
    }
    
    private func bindUI() {
        label.text = isWordSide ? vocabularyRealmModel?.word : vocabularyRealmModel?.note
    }
}
