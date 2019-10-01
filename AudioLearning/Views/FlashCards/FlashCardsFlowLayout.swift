//
//  FlashCardsFlowLayout.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class FlashCardsFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        let space: CGFloat = 20.0
        let side = UIScreen.main.bounds.width - (space * 2)
        itemSize = CGSize(width: side, height: side)
        scrollDirection = .horizontal
        minimumLineSpacing = space
//        sectionInset = UIEdgeInsets(top: 0, left: space, bottom: 0, right: space)
        if let collectionView = collectionView {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: space, bottom: 0, right: space)
        }
    }
}
