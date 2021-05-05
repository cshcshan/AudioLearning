//
//  VocabularyCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift

final class VocabularyCell: BaseTableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var longPress: UILongPressGestureRecognizer!
    
    private(set) var longPressSubject = PublishSubject<UILongPressGestureRecognizer>()
    private(set) var startWiggleAnimation = PublishSubject<Void>()
    private(set) var stopWiggleAnimation = PublishSubject<Void>()
    private(set) var deleteVocabulary = PublishSubject<VocabularyRealmModel>()
    private let highlightedSubject = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    
    var vocabularyRealmModel: VocabularyRealmModel? {
        didSet {
            bindUI()
        }
    }
    
    private let darkBgDeleteImage = UIImage(named: "remove-cell-white")
    private let lightBgDeleteImage = UIImage(named: "remove-cell")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBindings()
        addLongPressed()
    }
    
    override func layoutSubviews() {
        self.separatorInset = .zero
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        highlightedSubject.onNext(highlighted)
    }
    
    override func setupUIColor() {
        super.setupUIColor()
        highlightedSubject.onNext(false)
    }
    
    override func setupUI() {
        // round-corner
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        // deleteButton
        deleteButton.isHidden = true
    }
    
    private func setupBindings() {
        Observable.of(highlightedSubject)
            .merge()
            .subscribe(onNext: { [weak self] (isHighlighted) in
                guard let `self` = self else { return }
                self.backgroundColor = Appearance.secondaryBgColor
                self.containerView.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.wordLabel.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.wordLabel.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
                self.episodeLabel.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.episodeLabel.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
                self.deleteButton.setImage(Appearance.mode == .dark ?
                    self.darkBgDeleteImage : self.lightBgDeleteImage, for: UIControl.State())
            })
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                guard let model = self.vocabularyRealmModel else { return }
                self.deleteVocabulary.onNext(model)
            })
            .disposed(by: disposeBag)
        
        startWiggleAnimation
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.deleteButton.isHidden = false
                self.addWiggleAnimation()
            })
            .disposed(by: disposeBag)
        
        stopWiggleAnimation
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.deleteButton.isHidden = true
                self.removeWiggleAnimation()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindUI() {
        wordLabel.text = vocabularyRealmModel?.word
        episodeLabel.text = vocabularyRealmModel?.episode
    }
    
    private func addLongPressed() {
        guard longPress == nil else { return }
        longPress = UILongPressGestureRecognizer(target: nil, action: nil)
        addGestureRecognizer(longPress)
        longPress.rx.event
            .bind(to: longPressSubject)
            .disposed(by: disposeBag)
    }
}
