//
//  VocabularyCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import UIKit

final class VocabularyCell: BaseTableViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var episodeLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!

    private var longPress: UILongPressGestureRecognizer!

    private(set) var longPressSubject = PublishSubject<UILongPressGestureRecognizer>()
    private(set) var startWiggleAnimation = PublishSubject<Void>()
    private(set) var stopWiggleAnimation = PublishSubject<Void>()
    private(set) var deleteVocabulary = PublishSubject<VocabularyRealm>()
    private let highlightedSubject = PublishSubject<Bool>()
    private let bag = DisposeBag()

    var vocabularyRealm: VocabularyRealm? {
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
        separatorInset = .zero
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
        Observable
            .merge(highlightedSubject)
            .subscribe(onNext: { [weak self] isHighlighted in
                guard let self = self else { return }
                self.backgroundColor = Appearance.secondaryBgColor
                self.containerView.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.wordLabel.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.wordLabel.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
                self.episodeLabel.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.episodeLabel.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
                self.deleteButton.setImage(
                    Appearance.mode == .dark
                        ? self.darkBgDeleteImage
                        : self.lightBgDeleteImage,
                    for: .normal
                )
            })
            .disposed(by: bag)

        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let model = self.vocabularyRealm else { return }
                self.deleteVocabulary.onNext(model)
            })
            .disposed(by: bag)

        startWiggleAnimation
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.deleteButton.isHidden = false
                self.addWiggleAnimation()
            })
            .disposed(by: bag)

        stopWiggleAnimation
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.deleteButton.isHidden = true
                self.removeWiggleAnimation()
            })
            .disposed(by: bag)
    }

    private func bindUI() {
        wordLabel.text = vocabularyRealm?.word
        episodeLabel.text = vocabularyRealm?.episodeID
    }

    private func addLongPressed() {
        guard longPress == nil else { return }
        longPress = UILongPressGestureRecognizer(target: nil, action: nil)
        addGestureRecognizer(longPress)
        longPress.rx.event
            .bind(to: longPressSubject)
            .disposed(by: bag)
    }
}
