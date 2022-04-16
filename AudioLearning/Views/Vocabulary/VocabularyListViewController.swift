//
//  VocabularyListViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class VocabularyListViewController: BaseViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var maskView: UIView!
    @IBOutlet var vocabularyDetailContainerView: UIView!

    var viewModel: VocabularyListViewModel!
    var vocabularyDetailView: UIView!
    private var addItem: UIBarButtonItem!
    private var flashCardsItem: UIBarButtonItem!

    private var showEmptyView: ((UITableView) -> Void) = { tableView in
        tableView.showEmptyView(
            Appearance.backgroundColor,
            title: ("No words yet", Appearance.textColor),
            message: (
                "Tap Add to list and add words to show.",
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

        viewModel.event.fetchData.accept(())
    }

    override func setupUIID() {
        tableView.accessibilityIdentifier = "TableView"
    }

    override func setupUIColor() {
        super.setupUIColor()
        view.backgroundColor = Appearance.backgroundColor
        tableView.backgroundColor = Appearance.secondaryBgColor
        tableView.separatorColor = tableView.backgroundColor
        if tableView.backgroundView != nil { showEmptyView(tableView) }
        maskView.backgroundColor = Appearance.textColor.withAlphaComponent(0.4)
    }

    private func setupUI() {
        tableView.contentInsetAdjustmentBehavior = .never
        setupNavigationBar(0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
        showEmptyView(tableView)
        addTapToMaskView()
        // vocabularyDetailView
        vocabularyDetailContainerView.backgroundColor = .clear
        vocabularyDetailView.frame = vocabularyDetailContainerView.bounds
        vocabularyDetailContainerView.addSubview(vocabularyDetailView)
        vocabularyDetailView.layer.cornerRadius = 10
        // themeButton
        showThemeButton(viewModel, to: tableView)
    }

    private func setupNavigationBar(_ vocabulariesCount: Int) {
        if vocabulariesCount == 0 {
            navigationItem.rightBarButtonItems = [getAddItem()]
        } else {
            navigationItem.rightBarButtonItems = [getAddItem(), getFlashCardsItem()]
        }
        navigationItem.title = "Vocabulary"
    }

    private func getAddItem() -> UIBarButtonItem {
        if let item = addItem { return item }
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        item.accessibilityIdentifier = "Add"
        item.rx.tap
            .bind(to: viewModel.event.addVocabulary)
            .disposed(by: bag)
        addItem = item
        return item
    }

    private func getFlashCardsItem() -> UIBarButtonItem {
        if let item = flashCardsItem { return item }
        let item = UIBarButtonItem(image: UIImage(named: "flashcards"), style: .plain, target: nil, action: nil)
        item.rx.tap
            .bind(to: viewModel.event.flashCardsTapped)
            .disposed(by: bag)
        flashCardsItem = item
        return item
    }

    private func setupBindings() {
        viewModel.state.isVocabularyDetailViewHidden.asDriver().drive(maskView.rx.isHidden).disposed(by: bag)

        viewModel.state.isVocabularyDetailViewHidden
            .filter { $0 }
            .map { _ in TimeInterval(0.4) }
            .observe(on: MainScheduler.instance)
            .bind(to: maskView.rx.fadeOut)
            .disposed(by: bag)

        viewModel.state.isVocabularyDetailViewHidden
            .filter { $0 == false }
            .map { _ in TimeInterval(0.4) }
            .observe(on: MainScheduler.instance)
            .bind(to: maskView.rx.fadeIn)
            .disposed(by: bag)

        viewModel.state.vocabularies
            .do(onNext: { [weak self] vocabularies in
                guard let self = self else { return }
                self.setupNavigationBar(vocabularies.count)
                if vocabularies.isEmpty {
                    self.showEmptyView(self.tableView)
                } else {
                    self.hideEmptyView(self.tableView)
                }
            })
            .drive(
                tableView.rx.items(cellIdentifier: "VocabularyCell", cellType: VocabularyCell.self),
                curriedArgument: { [weak self] _, model, cell in
                    guard let self = self else { return }
                    cell.selectionStyle = .none
                    cell.vocabularyRealm = model
                    cell.longPressSubject
                        .subscribe(onNext: { _ in
                            cell.startWiggleAnimation.onNext(())
                        })
                        .disposed(by: self.bag)

                    Observable
                        .merge(
                            self.addItem.rx.tap.map { $0 as AnyObject },
                            self.tableView.rx.itemSelected.map { $0 as AnyObject }
                        )
                        .subscribe(onNext: { _ in
                            cell.stopWiggleAnimation.onNext(())
                        })
                        .disposed(by: self.bag)

                    let deleteValidated = cell.deleteVocabulary.filter { !$0.isInvalidated }.share()
                    deleteValidated.map { _ in }.bind(to: cell.stopWiggleAnimation).disposed(by: self.bag)
                    deleteValidated.bind(to: self.viewModel.event.deleteVocabulary).disposed(by: self.bag)
                }
            )
            .disposed(by: bag)

        tableView.rx.modelSelected(VocabularyRealm.self)
            .bind(to: viewModel.event.vocabularySelected)
            .disposed(by: bag)
    }
}

// MARK: - Tap Mask View

extension VocabularyListViewController {

    private func addTapToMaskView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapView))
        maskView.addGestureRecognizer(tap)
    }

    @objc func handleTapView(_ recognizer: UITapGestureRecognizer) {
        viewModel.state.isVocabularyDetailViewHidden.accept(true)
    }
}
