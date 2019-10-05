//
//  FlashCardsViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FlashCardsViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: FlashCardsViewModel!
    private var modelCount = 0
    private var currentIndex: Int?
    private var beganContentOffset: CGPoint = .zero
    private var startAngle: CGFloat = 0
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func setupUIColor() {
        view.backgroundColor = Appearance.backgroundColor
        collectionView.backgroundColor = Appearance.textColor
    }
    
    private func setupUI() {
        setupNavigationBar()
        addPanToView()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Flash Cards"
    }
    
    private func setupBindings() {
        viewModel.vocabularies
            .bind(to: collectionView.rx.items(cellIdentifier: "FlashCardCell", cellType: FlashCardCell.self), curriedArgument: { [weak self] (row, model, item) in
                guard let `self` = self else { return }
                item.vocabularyRealmModel = model
                item.flip(self.viewModel.wordSideArray[row])
            })
            .disposed(by: disposeBag)
        
        viewModel.vocabularies
            .subscribe(onNext: { [weak self] (vocabularyRealmModels) in
                guard let `self` = self else { return }
                self.modelCount = vocabularyRealmModels.count
                if self.modelCount > 0 && self.currentIndex == nil {
                    self.currentIndex = 0
                } else {
                    self.currentIndex = nil
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isWordSide
            .subscribe(onNext: { [weak self] (isWordSide) in
                guard let `self` = self else { return }
                guard let index = self.currentIndex, let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? FlashCardCell else { return }
                cell.flip(isWordSide)
            })
            .disposed(by: disposeBag)
        
        viewModel.load.onNext(())
    }
}

// MARK: - Pan

extension FlashCardsViewController {
    
    private func addPanToView() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        collectionView.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }
        let offset = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        let state = recognizer.state
        
        changeVisibleItem(state: state, offset: offset, velocity: velocity)
        flipItem(state: state, offset: offset, velocity: velocity)
    }
    
    private func changeVisibleItem(state: UIGestureRecognizer.State, offset: CGPoint, velocity: CGPoint) {
        switch state {
        case .began:
            beganContentOffset = collectionView.contentOffset
        case .changed:
            collectionView.contentOffset = CGPoint(x: beganContentOffset.x - offset.x, y: beganContentOffset.y)
        case .ended:
            guard var index = currentIndex else { return }
            if offset.x > 50 || velocity.x > 500 {
                index -= 1
            } else if offset.x < -50 || velocity.x < -500 {
                index += 1
            }
            if index < 0 { index = 0 }
            if index >= modelCount { index = modelCount - 1 }
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            currentIndex = index
        default: break
        }
    }
    
    private func flipItem(state: UIGestureRecognizer.State, offset: CGPoint, velocity: CGPoint) {
        guard state == .ended else { return }
        if offset.y > 100 || velocity.y > 500 || offset.y < -100 || velocity.y < -500 {
            guard let index = currentIndex else { return }
            viewModel.flip.onNext(index)
        }
    }
}
