//
//  VocabularyDetailViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class VocabularyDetailViewController: BaseViewController {

    @IBOutlet var wordTextField: UITextField!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!

    var viewModel: VocabularyDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func setupUIID() {
        wordTextField.accessibilityIdentifier = "Word"
        noteTextView.accessibilityIdentifier = "Note"
        saveButton.accessibilityIdentifier = "Save"
        cancelButton.accessibilityIdentifier = "Cancel"
    }

    override func setupUIColor() {
        super.setupUIColor()
        view.backgroundColor = Appearance.backgroundColor
        wordTextField.backgroundColor = Appearance.backgroundColor
        wordTextField.tintColor = Appearance.textColor
        wordTextField.textColor = Appearance.textColor
        wordTextField.layer.borderColor = Appearance.textColor.cgColor
        noteTextView.backgroundColor = Appearance.backgroundColor
        noteTextView.tintColor = Appearance.textColor
        noteTextView.textColor = Appearance.textColor
        noteTextView.layer.borderColor = Appearance.textColor.cgColor
        saveButton.backgroundColor = Appearance.backgroundColor
        saveButton.setTitleColor(Appearance.textColor, for: .normal)
        saveButton.layer.borderColor = Appearance.textColor.cgColor
        cancelButton.backgroundColor = Appearance.backgroundColor
        cancelButton.setTitleColor(Appearance.textColor, for: .normal)
        cancelButton.layer.borderColor = Appearance.textColor.cgColor
    }

    private func setupUI() {
        wordTextField.attributedPlaceholder = NSAttributedString(
            string: "Word",
            attributes: [
                NSAttributedString.Key
                    .foregroundColor: UIColor.lightGray
                    .withAlphaComponent(0.4)
            ]
        )
        wordTextField.layer.cornerRadius = 3
        wordTextField.layer.borderWidth = 1
        noteTextView.layer.cornerRadius = 3
        noteTextView.layer.borderWidth = 1
        noteTextView.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        saveButton.layer.cornerRadius = 3
        saveButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 3
        cancelButton.layer.borderWidth = 1
    }

    private func setupBindings() {
        viewModel.state.word.drive(wordTextField.rx.text).disposed(by: bag)
        viewModel.state.note.drive(noteTextView.rx.text).disposed(by: bag)

        saveButton.rx.tap
            .map { [wordTextField, noteTextView] _ in
                VocabularySaveModel(word: wordTextField?.text, note: noteTextView?.text)
            }
            .bind(to: viewModel.event.save)
            .disposed(by: bag)

        cancelButton.rx.tap.bind(to: viewModel.event.cancel).disposed(by: bag)

        Signal
            .merge(viewModel.event.saveSuccessfully.asSignal(), viewModel.event.cancel.asSignal())
            .emit(onNext: { [navigationController, view] _ in
                navigationController?.view.endEditing(true)
                view?.endEditing(true)
            })
            .disposed(by: bag)
    }
}
