//
//  VocabularyDetailViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VocabularyDetailViewController: BaseViewController {
    
    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var viewModel: VocabularyDetailViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    override func setupUIColor() {
        view.backgroundColor = Appearance.backgroundColor
        wordTextField.backgroundColor = Appearance.backgroundColor
        wordTextField.textColor = Appearance.textColor
        noteTextView.backgroundColor = Appearance.backgroundColor
        noteTextView.textColor = Appearance.textColor
        saveButton.backgroundColor = Appearance.backgroundColor
        saveButton.setTitleColor(Appearance.textColor, for: UIControl.State())
        cancelButton.backgroundColor = Appearance.backgroundColor
        cancelButton.setTitleColor(Appearance.textColor, for: UIControl.State())
    }
    
    private func setupBindings() {
        viewModel.word
            .bind(to: wordTextField.rx.text)
            .disposed(by: disposeBag)
        viewModel.note
            .bind(to: noteTextView.rx.text)
            .disposed(by: disposeBag)
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                let model = VocabularySaveModel(episode: nil,
                                                word: self.wordTextField.text,
                                                note: self.noteTextView.text)
                self.viewModel.save.onNext(model)
            })
            .disposed(by: disposeBag)
        cancelButton.rx.tap
            .bind(to: viewModel.cancel)
            .disposed(by: disposeBag)
    }
}
