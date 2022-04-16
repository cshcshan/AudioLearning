//
//  EpisodeCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import UIKit

final class EpisodeCell: BaseTableViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
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
    private var disposeBag = DisposeBag()

    var viewModel: EpisodeCellViewModel? {
        didSet {
            bindViewModel()
        }
    }

    // MARK: - View Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupColorBindings()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        photoImageView.image = nil
    }

    override func layoutSubviews() {
        separatorInset = .zero
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
            .subscribe(onNext: { [weak self] isHighlighted in
                guard let self = self else { return }
                self.backgroundColor = Appearance.secondaryBgColor
                self.containerView.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.titleLabel.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.titleLabel.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
                self.dateLabel.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.dateLabel.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
                self.descLabel.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
                self.descLabel.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
                if self.photoImageView.image == self.darkBgTempImage || self.photoImageView.image == self
                    .lightBgTempImage {
                    self.photoImageView.image = isHighlighted ? self.getHighlightedImage() : self.getNormalImage()
                }
                self.indicatorView.color = Appearance.mode == .dark ? .white : .gray
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Bind

    private func bindViewModel() {
        viewModel?.outputs.title.drive(titleLabel.rx.text).disposed(by: disposeBag)
        viewModel?.outputs.date.drive(dateLabel.rx.text).disposed(by: disposeBag)
        viewModel?.outputs.desc.drive(descLabel.rx.text).disposed(by: disposeBag)

        viewModel?.outputs.image
            .map { [weak self] image in image == nil ? self?.getNormalImage() : image }
            .drive(photoImageView.rx.image).disposed(by: disposeBag)

        viewModel?.outputs.imageRefreshing
            .map { !$0 }
            .do(
                onNext: { [indicatorView] isRefreshing in
                    if isRefreshing {
                        indicatorView?.startAnimating()
                    }
                },
                afterNext: { [indicatorView] isRefreshing in
                    if !isRefreshing {
                        indicatorView?.stopAnimating()
                    }
                }
            )
            .emit(to: indicatorView.rx.isHidden)
            .disposed(by: disposeBag)
    }

    private func getNormalImage() -> UIImage? {
        Appearance.mode == .dark ? darkBgTempImage : lightBgTempImage
    }

    private func getHighlightedImage() -> UIImage? {
        Appearance.mode == .dark ? lightBgTempImage : darkBgTempImage
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
                descLabelRight = NSLayoutConstraint(
                    item: descLabel!,
                    attribute: .right,
                    relatedBy: .equal,
                    toItem: containerView!,
                    attribute: .right,
                    multiplier: 1,
                    constant: -10
                )
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
