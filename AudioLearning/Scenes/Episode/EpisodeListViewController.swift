//
//  EpisodeListViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/3.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class EpisodeListViewController: BaseViewController {

    @IBOutlet var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    var viewModel: EpisodeListViewModel!
    // This is for push or pop animator
    var selectedCell: EpisodeCell?

    private var showEmptyView: ((UITableView) -> Void) = { tableView in
        tableView.showEmptyView(
            Appearance.backgroundColor,
            title: ("No episodes of 6 Minute English", Appearance.textColor),
            message: (
                "Wait to download episode list from server.",
                Appearance.textColor.withAlphaComponent(0.6)
            )
        )
    }

    private var hideEmptyView: ((UITableView) -> Void) = { tableView in
        tableView.hideEmptyView(nil, separatorStyle: .singleLine)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()

        viewModel.event.fetchDataWithIsFirstTime.accept(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatePlayingButton()
    }

    override func setupNotification() {
        super.setupNotification()
        NotificationCenter.default.rx
            .notification(.isPlaying)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] notification in
                guard let self = self else { return }
                guard let userInfo = notification.userInfo else { return }
                guard let isPlaying = userInfo["isPlaying"] as? Bool else { return }
                self.showPlayingButton(self.viewModel, to: self.tableView, isShow: isPlaying)
            })
            .disposed(by: bag)
    }

    override func setupUIColor() {
        super.setupUIColor()
        view.backgroundColor = Appearance.backgroundColor
        tableView.backgroundColor = Appearance.secondaryBgColor
        tableView.separatorColor = tableView.backgroundColor
        if tableView.backgroundView != nil { showEmptyView(tableView) }
        refreshControl.tintColor = Appearance.textColor
    }

    private func setupUI() {
        tableView.contentInsetAdjustmentBehavior = .never
        setupNavigationBar()
        // refreshControl
        if !isUITesting {
            refreshControl.sendActions(for: .valueChanged)
            tableView
                .contentOffset = CGPoint(
                    x: 0,
                    y: -refreshControl.frame.height
                ) // for changing refreshControl's tintColor
            tableView.insertSubview(refreshControl, at: 0)
        }
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 165
        tableView.separatorStyle = .none
        showEmptyView(tableView)
        // themeButton
        showThemeButton(viewModel, to: tableView)
    }

    private func setupNavigationBar() {
        let image = UIImage(named: "dictionary-filled")
        let vocabularyItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        vocabularyItem.accessibilityIdentifier = "VocabularyButton"
        vocabularyItem.rx.tap.bind(to: viewModel.event.vocabularyTapped).disposed(by: bag)
        navigationItem.rightBarButtonItems = [vocabularyItem]
        navigationItem.title = "6 Minute English"
    }

    private func setupBindings() {
        // ViewModel's output to the ViewController
        viewModel.state.cellViewModels
            .do(onNext: { [weak self] cellViewModels in
                guard let self = self else { return }
                if cellViewModels.isEmpty {
                    self.showEmptyView(self.tableView)
                } else {
                    self.hideEmptyView(self.tableView)
                }
                self.refreshControl.endRefreshing()
            })
            .drive(
                tableView.rx.items(cellIdentifier: EpisodeCell.cellIdentifier, cellType: EpisodeCell.self)
            ) { [weak self] row, item, cell in
                guard let self = self else { return }
                cell.accessibilityIdentifier = "EpisodeCell_\(row)"
                cell.viewModel = item
            }
            .disposed(by: bag)

        if !isUITesting {
            viewModel.state.isRefreshing.drive(refreshControl.rx.isRefreshing).disposed(by: bag)
        }

        viewModel.event.showAlert.asSignal()
            .emit(with: self, onNext: { `self`, alert in
                self.showConfirmAlert(
                    title: alert.title,
                    message: alert.message,
                    confirmHandler: nil,
                    completionHandler: nil
                )
            })
            .disposed(by: bag)

        if !isUITesting {
            refreshControl.rx.controlEvent(.valueChanged)
                .map { _ in false }
                .bind(to: viewModel.event.fetchDataWithIsFirstTime)
                .disposed(by: bag)
        }

        tableView.rx.itemSelected
            .do(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.selectedCell = self.tableView.cellForRow(at: indexPath) as? EpisodeCell
            })
            .map(\.row)
            .bind(to: viewModel.event.episodeSelected)
            .disposed(by: bag)
    }
}
