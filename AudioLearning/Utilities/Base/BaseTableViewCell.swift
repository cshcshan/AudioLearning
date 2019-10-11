//
//  BaseTableViewCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/25.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift

class BaseTableViewCell: UITableViewCell {
    
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupNotification()
        setupUIColor()
        setupUI()
    }
    
    private func setupNotification() {
        NotificationCenter.default.rx
            .notification(.changeAppearance)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.setupUIColor()
            })
            .disposed(by: disposeBag)
    }
    
    func setupUIColor() {}
    func setupUI() {}
}
