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
    @IBOutlet weak var vocabularyDetailView: UIView!
    
    var viewModel: VocabularyListViewModel!
    var vocabularyDetailViewController: VocabularyDetailViewController!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func setupUIColor() {
        view.backgroundColor = Appearance.backgroundColor
        tableView.backgroundColor = Appearance.backgroundColor
        maskView.backgroundColor = (appearanceMode == .dark ? Appearance.textColor : Appearance.backgroundColor).withAlphaComponent(0.4)
    }
    
    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        // vocabularyDetailView
        addChild(vocabularyDetailViewController)
        vocabularyDetailView.backgroundColor = .clear
        vocabularyDetailViewController.view.frame = vocabularyDetailView.bounds
        vocabularyDetailView.addSubview(vocabularyDetailViewController.view)
        vocabularyDetailViewController.view.layer.cornerRadius = 10
    }
    
    private func setupNavigationBar() {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        addItem.rx.tap
            .bind(to: viewModel.addVocabulary)
            .disposed(by: disposeBag)
        navigationItem.rightBarButtonItems = [addItem]
        navigationItem.title = "Vocabulary"
    }
    
    private func setupBindings() {
        viewModel.hideVocabularyDetailView
            .bind(to: maskView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.vocabularies
            .bind(to: tableView.rx.items(cellIdentifier: "VocabularyCell", cellType: VocabularyCell.self), curriedArgument: { (_, model, cell) in
                cell.vocabularyRealmModel = model
            })
            .disposed(by: disposeBag)
        
        viewModel.showVocabularyDetail
            .subscribe(onNext: { [weak self] (vocabularyRealmModel) in
                guard let `self` = self else { return }
                self.vocabularyDetailViewController.viewModel.load.onNext(vocabularyRealmModel)
            })
            .disposed(by: disposeBag)
        
        viewModel.showAddVocabularyDetail
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.vocabularyDetailViewController.viewModel.add.onNext(())
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
