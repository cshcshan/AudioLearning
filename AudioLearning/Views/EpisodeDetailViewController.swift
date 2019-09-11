//
//  EpisodeDetailViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/3.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EpisodeDetailViewController: BaseViewController, StoryboardGettable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var htmlTextView: UITextView!
    private let refreshControl = UIRefreshControl()
    
    var viewModel: EpisodeDetailViewModel!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        scrollView.isScrollEnabled = false
        scrollView.addSubview(refreshControl)
        htmlTextView.isEditable = false
        htmlTextView.isScrollEnabled = true
    }
    
    private func setupBindings() {
        viewModel.refreshing
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (refreshing) in
                guard let `self` = self else { return }
                if refreshing {
                    self.refreshControl.beginRefreshing()
                } else {
                    self.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.scriptHtml
            .observeOn(MainScheduler.instance)
            .map({ [weak self] (html) -> NSAttributedString in
                guard let `self` = self else { return NSAttributedString() }
                let fontName = self.htmlTextView.font!.fontName
                let fontSize = self.htmlTextView.font!.pointSize
                return "<style>body{font-family:'\(fontName)';font-size:\(fontSize)px;}</style>\(html)".convertHtml()
            })
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.refreshControl.endRefreshing()
            })
            .bind(to: htmlTextView.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel.alert
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (alert) in
                guard let `self` = self else { return }
                self.showConfirmAlert(title: alert.title,
                                      message: alert.message,
                                      confirmHandler: nil,
                                      completionHandler: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.reload.onNext(())
    }
}
