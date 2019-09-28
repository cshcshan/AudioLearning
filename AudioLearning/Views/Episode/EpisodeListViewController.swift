//
//  EpisodeListViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/3.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EpisodeListViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    var viewModel: EpisodeListViewModel!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func setupUIColor() {
        view.backgroundColor = Appearance.backgroundColor
        tableView.backgroundColor = Appearance.backgroundColor
    }
    
    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar()
        // refreshControl
        refreshControl.sendActions(for: .valueChanged)
        refreshControl.tintColor = Appearance.textColor
        tableView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.height) // for changing refreshControl's tintColor
        tableView.insertSubview(refreshControl, at: 0)
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    private func setupNavigationBar() {
        let image = UIImage(named: "dictionary-filled")
        let vocabularyItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        vocabularyItem.rx.tap
            .bind(to: viewModel.tapVocabulary)
            .disposed(by: disposeBag)
        navigationItem.rightBarButtonItems = [vocabularyItem]
        navigationItem.title = "6 Minute English"
    }

    private func setupBindings() {
        // ViewModel's output to the ViewController
        viewModel.episodes
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.refreshControl.endRefreshing()
            })
            .bind(to: tableView.rx.items(cellIdentifier: "EpisodeCell", cellType: EpisodeCell.self),
                  curriedArgument: { (row, model, cell) in
                    cell.selectionStyle = .none
                    cell.episodeModel = model
            })
            .disposed(by: disposeBag)
        
        viewModel.refreshing
            .bind(to: refreshControl.rx.isRefreshing)
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
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(EpisodeModel.self)
            .bind(to: viewModel.selectEpisode)
            .disposed(by: disposeBag)
        
        // ViewController's UI actions to ViewModel
        viewModel.initalLoad.onNext(())
    }
}
