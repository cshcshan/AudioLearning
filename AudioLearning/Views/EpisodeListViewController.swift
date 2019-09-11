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

class EpisodeListViewController: UIViewController, StoryboardGettable {
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    var viewModel: EpisodeListViewModel!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        refreshControl.sendActions(for: .valueChanged)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.insertSubview(refreshControl, at: 0)
    }

    private func setupBindings() {
        
        // ViewModel's output to the ViewController
        viewModel.episodes
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] (_) in
                self?.refreshControl.endRefreshing()
            })
            .bind(to: tableView.rx.items(cellIdentifier: "EpisodeCell", cellType: EpisodeCell.self),
                  curriedArgument: { (row, model, cell) in
                cell.episodeModel = model
            })
            .disposed(by: disposeBag)
        
        viewModel.refreshing
            .subscribe(onNext: { (refreshing) in
                if refreshing {
                    self.refreshControl.beginRefreshing()
                } else {
                    self.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.alert
            .subscribe(onNext: { (alert) in
                print("alert title: \(alert.title ?? ""), message: \(alert.message ?? "")")
            })
            .disposed(by: disposeBag)
        
        // ViewController's UI actions to ViewModel
        viewModel.reload.on(.next(()))
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
    }
}
