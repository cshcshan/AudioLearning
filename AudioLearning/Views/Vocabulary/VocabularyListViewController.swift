//
//  VocabularyListViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VocabularyListViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var vocabularyDetailContainerView: UIView!
    
    var viewModel: VocabularyListViewModel!
    var vocabularyDetailView: UIView!
    private var addItem: UIBarButtonItem!
    private var flashCardsItem: UIBarButtonItem!
    
    private var showEmptyView: ((UITableView) -> Void) = { tableView in
        tableView.showEmptyView(Appearance.backgroundColor,
                                title: ("No words yet", Appearance.textColor),
                                message: ("Tap Add to list and add words to show.", Appearance.textColor.withAlphaComponent(0.6)))
    }
    private var hideEmptyView: ((UITableView) -> Void) = { tableView in
        tableView.hideEmptyView(nil, separatorStyle: .singleLine)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func setupUIID() {
        tableView.accessibilityIdentifier = "TableView"
    }
    
    override func setupUIColor() {
        super.setupUIColor()
        view.backgroundColor = Appearance.backgroundColor
        tableView.backgroundColor = Appearance.backgroundColor
        if tableView.backgroundView != nil { showEmptyView(tableView) }
        maskView.backgroundColor = Appearance.textColor.withAlphaComponent(0.4)
    }
    
    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar(0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        showEmptyView(tableView)
        // vocabularyDetailView
        vocabularyDetailContainerView.backgroundColor = .clear
        vocabularyDetailView.frame = vocabularyDetailContainerView.bounds
        vocabularyDetailContainerView.addSubview(vocabularyDetailView)
        vocabularyDetailView.layer.cornerRadius = 10
        // themeButton
        addThemeButton(viewModel, to: tableView)
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
            .bind(to: viewModel.addVocabulary)
            .disposed(by: disposeBag)
        addItem = item
        return item
    }
    
    private func getFlashCardsItem() -> UIBarButtonItem {
        if let item = flashCardsItem { return item }
        let item = UIBarButtonItem(image: UIImage(named: "flashcards"), style: .plain, target: nil, action: nil)
        item.rx.tap
            .bind(to: viewModel.tapFlashCards)
            .disposed(by: disposeBag)
        flashCardsItem = item
        return item
    }
    
    private func setupBindings() {
        viewModel.hideVocabularyDetailView
            .bind(to: maskView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.hideVocabularyDetailView
            .filter({ $0 == true })
            .flatMap({ (_) -> Observable<TimeInterval> in
                return .just(TimeInterval(0.4))
            })
            .bind(to: maskView.rx.fadeOut)
            .disposed(by: disposeBag)
        
        viewModel.hideVocabularyDetailView
            .filter({ $0 == false })
            .flatMap({ (_) -> Observable<TimeInterval> in
                return .just(TimeInterval(0.4))
            })
            .bind(to: maskView.rx.fadeIn)
            .disposed(by: disposeBag)
        
        viewModel.vocabularies
            .do(onNext: { [weak self] (vocabularies) in
                guard let `self` = self else { return }
                self.setupNavigationBar(vocabularies.count)
                if vocabularies.count == 0 {
                    self.showEmptyView(self.tableView)
                } else {
                    self.hideEmptyView(self.tableView)
                }
            })
            .bind(to: tableView.rx.items(cellIdentifier: "VocabularyCell", cellType: VocabularyCell.self), curriedArgument: { (_, model, cell) in
                cell.selectionStyle = .none
                cell.vocabularyRealmModel = model
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(VocabularyRealmModel.self)
            .bind(to: viewModel.selectVocabulary)
            .disposed(by: disposeBag)
        
        tableView.rx.modelDeleted(VocabularyRealmModel.self)
            .bind(to: viewModel.deleteVocabulary)
            .disposed(by: disposeBag)
        
        viewModel.reload.onNext(())
    }
}
