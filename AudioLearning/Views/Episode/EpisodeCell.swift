//
//  EpisodeCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift

final class EpisodeCell: BaseTableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet var photoImageView: UIImageView! // remove weak mark because instance will be immediately deallocated because property is 'weak'
    // remove weak mark because instance will be immediately deallocated because property is 'weak'
    @IBOutlet var photoImageViewLeft: NSLayoutConstraint!
    @IBOutlet var photoImageViewRight: NSLayoutConstraint!
    @IBOutlet var photoImageViewTop: NSLayoutConstraint!
    @IBOutlet var photoImageViewBottom: NSLayoutConstraint!
    private var descLabelRight: NSLayoutConstraint!
    
    private let darkBgTempImage = UIImage(named: "temp_pic-white")
    private let lightBgTempImage = UIImage(named: "temp_pic")
    
    private let highlightedSubject = PublishSubject<Bool>()
    private let selectedSubject = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    private var titleDisposable: Disposable?
    private var dateDisposable: Disposable?
    private var descDisposable: Disposable?
    private var imageDisposable: Disposable?
    private var imageRefreshingDisposable: Disposable?
    
    var viewModel: EpisodeCellViewModel? {
        didSet {
            setupBindings()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupColorBindings()
    }
    
    override func layoutSubviews() {
        self.separatorInset = .zero
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        highlightedSubject.onNext(highlighted)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedSubject.onNext(selected)
    }
    
    override func setupUIColor() {
        super.setupUIColor()
        highlightedSubject.onNext(false)
    }
    
    override func setupUI() {
        // round-corner
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
    }
    
    private func setupColorBindings() {
        Observable.of(highlightedSubject, selectedSubject)
            .merge()
            .subscribe(onNext: { [weak self] (isHighlighted) in
                guard let self = self else { return }
                self.backgroundColor = Appearance.secondaryBgColor
                self.containerView.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.titleLabel.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.titleLabel.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
                self.dateLabel.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.dateLabel.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
                self.descLabel.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.descLabel.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
                if self.photoImageView.image == self.darkBgTempImage || self.photoImageView.image == self.lightBgTempImage {
                    self.photoImageView.image = isHighlighted ? self.getHighlightedImage() : self.getNormalImage()
                }
                self.indicatorView.style = Appearance.mode == .dark ? .white : .gray
            })
            .disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        titleDisposable?.dispose()
        dateDisposable?.dispose()
        descDisposable?.dispose()
        imageDisposable?.dispose()
        imageRefreshingDisposable?.dispose()

        titleDisposable = viewModel?.title.bind(to: titleLabel.rx.text)
        dateDisposable = viewModel?.date.bind(to: dateLabel.rx.text)
        descDisposable = viewModel?.desc.bind(to: descLabel.rx.text)
        imageDisposable = viewModel?.image
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (image) in
                guard let self = self else { return }
                if image == nil {
                    self.photoImageView.image = self.getNormalImage()
                } else {
                    self.photoImageView.image = image
                }
            })
        imageRefreshingDisposable = viewModel?.imageRefreshing
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (isRefreshing) in
                guard let self = self else { return }
                if isRefreshing {
                    self.indicatorView.isHidden = false
                    self.indicatorView.startAnimating()
                } else {
                    self.indicatorView.stopAnimating()
                    self.indicatorView.isHidden = true
                }
            })
    }
    
    private func getNormalImage() -> UIImage? {
        return Appearance.mode == .dark ? darkBgTempImage : lightBgTempImage
    }
    
    private func getHighlightedImage() -> UIImage? {
        return Appearance.mode == .dark ? lightBgTempImage : darkBgTempImage
    }
    
    private func hidePhotoImageView(_ isHidden: Bool) {
        photoImageView.isHidden = isHidden
        // remove first, then add constranits, otherwise app will get errors of auto-layout
        if isHidden {
            containerView.removeConstraint(photoImageViewLeft)
            containerView.removeConstraint(photoImageViewRight)
            containerView.removeConstraint(photoImageViewTop)
            containerView.removeConstraint(photoImageViewBottom)
            if descLabelRight == nil {
                descLabelRight = NSLayoutConstraint(item: descLabel!, attribute: .right, relatedBy: .equal, toItem: containerView!, attribute: .right, multiplier: 1, constant: -10)
            }
            containerView.addConstraint(descLabelRight)
        } else {
            if descLabelRight != nil {
                containerView.removeConstraint(descLabelRight)
            }
            containerView.addConstraint(photoImageViewLeft)
            containerView.addConstraint(photoImageViewRight)
            containerView.addConstraint(photoImageViewTop)
            containerView.addConstraint(photoImageViewBottom)
        }
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
    }
}
