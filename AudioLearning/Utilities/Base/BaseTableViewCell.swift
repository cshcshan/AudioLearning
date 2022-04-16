//
//  BaseTableViewCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/25.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import UIKit

class BaseTableViewCell: UITableViewCell {

    private let bag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupNotification()
        setupUIColor()
        setupUI()
    }

    private func setupNotification() {
        NotificationCenter.default.rx
            .notification(.changeAppearance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.setupUIColor()
            })
            .disposed(by: bag)
    }

    func setupUIColor() {}
    func setupUI() {}
}
