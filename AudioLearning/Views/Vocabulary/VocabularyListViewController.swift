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
        vocabularyDetailContainerView.backgroundColor = .clear
        vocabularyDetailView.frame = vocabularyDetailContainerView.bounds
        vocabularyDetailContainerView.addSubview(vocabularyDetailView)
        vocabularyDetailView.layer.cornerRadius = 10
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
