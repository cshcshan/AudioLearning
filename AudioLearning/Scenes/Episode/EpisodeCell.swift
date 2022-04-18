//
//  EpisodeCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import UIKit

final class EpisodeCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var photoImageViewLeft: NSLayoutConstraint!
    @IBOutlet var photoImageViewRight: NSLayoutConstraint!
    @IBOutlet var photoImageViewTop: NSLayoutConstraint!
    @IBOutlet var photoImageViewBottom: NSLayoutConstraint!
    private var descLabelRight: NSLayoutConstraint!

    // MARK: - Properties

    var viewModel: EpisodeCellViewModel? {
        didSet {
            bindViewModel()
        }
    }

    private let darkBgTempImage = UIImage(named: "temp_pic-white")
    private let lightBgTempImage = UIImage(named: "temp_pic")
    private let bag = DisposeBag()

    private var normalImage: UIImage? {
        Appearance.mode == .dark ? darkBgTempImage : lightBgTempImage
    }

    private var highlightedImage: UIImage? {
        Appearance.mode == .dark ? lightBgTempImage : darkBgTempImage
    }

    // MARK: - View Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupNotification()
        setupUI()
        updateUI(isHighlighted: isHighlighted || isSelected)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        updateUI(isHighlighted: highlighted)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        updateUI(isHighlighted: selected)
    }

    // MARK: - Setup

    private func setupNotification() {
        NotificationCenter.default.rx.notification(.changeAppearance)
            .take(until: rx.deallocated)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { `self`, _ in
                self.updateUI(isHighlighted: self.isHighlighted || self.isSelected)
            })
            .disposed(by: bag)
    }

    private func setupUI() {
        selectionStyle = .none
        // round-corner
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
    }

    private func updateUI(isHighlighted: Bool) {
        backgroundColor = Appearance.secondaryBgColor

        [containerView, titleLabel, dateLabel, descLabel].forEach {
            $0?.backgroundColor = isHighlighted ? Appearance.textColor : Appearance.backgroundColor
        }

        [titleLabel, dateLabel, descLabel].forEach {
            $0?.textColor = isHighlighted ? Appearance.backgroundColor : Appearance.textColor
        }

        titleLabel.text = viewModel?.title
        dateLabel.text = viewModel?.date
        descLabel.text = viewModel?.desc

        if photoImageView.image == darkBgTempImage || photoImageView.image == lightBgTempImage {
            photoImageView.image = isHighlighted ? highlightedImage : normalImage
        }

        indicatorView.color = Appearance.mode == .dark ? .white : .gray
    }

    // MARK: - Bind

    private func bindViewModel() {
        viewModel?.state.image
            .map { [weak self] image in image == nil ? self?.normalImage : image }
            .drive(photoImageView.rx.image)
            .disposed(by: bag)

        viewModel?.state.isImageRefreshing
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
            .drive(indicatorView.rx.isHidden)
            .disposed(by: bag)
    }
}
