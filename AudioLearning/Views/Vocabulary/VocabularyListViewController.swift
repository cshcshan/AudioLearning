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
    private let disposeBag = DisposeBag()
    
    var viewModel: VocabularyListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar()
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
        viewModel.vocabularies
            .bind(to: tableView.rx.items(cellIdentifier: "VocabularyCell", cellType: VocabularyCell.self), curriedArgument: { (_, model, cell) in
                cell.vocabularyRealmModel = model
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(VocabularyRealmModel.self)
            .bind(to: viewModel.selectVocabulary)
            .disposed(by: disposeBag)
        
        viewModel.reload.onNext(())
    }
}
