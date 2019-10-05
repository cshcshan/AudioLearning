//
//  VocabularyListViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class VocabularyListViewModel: BaseViewModel {
    
    // Inputs and Outputs
    private(set) var hideVocabularyDetailView = BehaviorSubject<Bool>(value: true)
    
    // Inputs
    private(set) var setEpisode: AnyObserver<String?>!
    private(set) var reload: AnyObserver<Void>!
    private(set) var selectVocabulary: AnyObserver<VocabularyRealmModel>!
    private(set) var addVocabulary: AnyObserver<Void>!
    private(set) var deleteVocabulary: AnyObserver<VocabularyRealmModel>!
    private(set) var tapFlashCards: AnyObserver<Void>!
    
    // Outputs
    private(set) var vocabularies: Observable<[VocabularyRealmModel]>!
    private(set) var showVocabularyDetail: Observable<VocabularyRealmModel>!
    private(set) var showAddVocabularyDetail: Observable<Void>!
    private(set) var showFlashCards: Observable<Void>!
    
    private let setEpisodeSubject = PublishSubject<String?>()
    private let reloadSubject = PublishSubject<Void>()
    private let selectVocabularySubject = PublishSubject<VocabularyRealmModel>()
    private let addVocabularySubject = PublishSubject<Void>()
    private let deleteVocabularySubject = PublishSubject<VocabularyRealmModel>()
    private let tapFlashCardsSubject = PublishSubject<Void>()
    
    private var episode: String?
    
    init(realmService: RealmService<VocabularyRealmModel>) {
        setEpisode = setEpisodeSubject.asObserver()
        reload = reloadSubject.asObserver()
        vocabularies = Observable.of(realmService.allObjects, realmService.filterObjects).merge()
        selectVocabulary = selectVocabularySubject.asObserver()
        showVocabularyDetail = selectVocabularySubject.asObservable()
        addVocabulary = addVocabularySubject.asObserver()
        showAddVocabularyDetail = addVocabularySubject.asObservable()
        deleteVocabulary = deleteVocabularySubject.asObserver()
        tapFlashCards = tapFlashCardsSubject.asObserver()
        showFlashCards = tapFlashCardsSubject.asObservable()
        super.init()
        
        Observable.of(showVocabularyDetail.map({ $0 as AnyObject }),
                      showAddVocabularyDetail.map({ $0 as AnyObject }))
            .merge()
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.hideVocabularyDetailView.onNext(false)
            })
            .disposed(by: disposeBag)
        
        setEpisodeSubject
            .subscribe(onNext: { [weak self] (episode) in
                guard let `self` = self else { return }
                self.episode = episode
            })
            .disposed(by: disposeBag)
        
        reloadSubject
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                let sortedByAsc = ["updateDate": false]
                if let episode = self.episode {
                    realmService.filter.onNext((NSPredicate(format: "episode == %@", episode), sortedByAsc))
                } else {
                    realmService.loadAll.onNext(sortedByAsc)
                }
            })
            .disposed(by: disposeBag)
        
        let deleteSuccessSubject = PublishSubject<Bool>()
        deleteSuccessSubject
            .subscribe(onNext: { [weak self] (success) in
                guard let `self` = self else { return }
                guard success else { return }
                self.reloadSubject.onNext(())
            })
            .disposed(by: disposeBag)
        
        deleteVocabularySubject
            .subscribe(onNext: { [weak self] (vocabularyRealmModel) in
                guard let `self` = self else { return }
                guard let id = vocabularyRealmModel.id else { return }
                realmService.delete(predicate: NSPredicate(format: "id == %@", id))
                    .subscribe(onNext: { (success) in
                        deleteSuccessSubject.onNext(success)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
