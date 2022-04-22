//
//  VocabularyDetailViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift

final class VocabularyDetailViewModel: BaseViewModel {

    struct EpisodeWord {
        let episodeID: String?
        let word: String
    }

    struct State {
        let word: Driver<String?>
        let note: Driver<String?>
        let vocabulary = BehaviorRelay<VocabularyRealm?>(value: nil)
    }

    struct Event {
        let reset = PublishRelay<Void>()
        let addEpisodeWord = PublishRelay<EpisodeWord>()
        let save = PublishRelay<VocabularySaveModel>()
        let saveSuccessfully = PublishRelay<Void>()
        let cancel = PublishRelay<Void>()
        let showAlert = PublishRelay<AlertModel>()
    }

    // MARK: - Properties

    lazy var state = State(word: word.asDriver(), note: note.asDriver())
    let event = Event()

    // Outputs
    private let word = BehaviorRelay<String?>(value: nil)
    private let note = BehaviorRelay<String?>(value: nil)

    private let realmService: RealmService<VocabularyRealm>
    private var model: VocabularyRealm?
    private var episodeID: String?

    init(realmService: RealmService<VocabularyRealm>) {
        self.realmService = realmService
        super.init()

        event.reset
            .subscribe(onNext: { [weak self] in self?.model = nil })
            .disposed(by: bag)

        let addEpisodeWord = event.addEpisodeWord
            .do(onNext: { [weak self] episodeWord in
                self?.model = nil
                self?.episodeID = episodeWord.episodeID
            })
            .share()

        Observable
            .merge(
                realmService.filterObjects.compactMap(\.first).map(\.word),
                state.vocabulary.map { $0?.word },
                event.reset.map { _ in nil }
            )
            .bind(to: word)
            .disposed(by: bag)

        addEpisodeWord.map(\.word).debug().bind(to: word).disposed(by: bag)

        Observable
            .merge(
                realmService.filterObjects.compactMap(\.first).map(\.note),
                state.vocabulary.map { $0?.note },
                event.reset.map { _ in nil },
                addEpisodeWord.map { _ in nil }
            )
            .bind(to: note)
            .disposed(by: bag)

        addEpisodeWord
            .map { episodeWord in
                var predicate = NSPredicate(format: "word == %@", episodeWord.word)
                if let episodeID = episodeWord.episodeID {
                    let episodePredicate = NSPredicate(format: "id == %@", episodeID)
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, episodePredicate])
                }
                return (predicate, nil)
            }
            .bind(to: realmService.filter)
            .disposed(by: bag)

        event.save
            .filter { $0.word?.isEmpty ?? true }
            .map { _ in AlertModel(title: "Save word failed", message: "Word cannot be empty.") }
            .bind(to: event.showAlert)
            .disposed(by: bag)

        event.save
            .filter {
                let isWordEmpty = $0.word?.isEmpty ?? true
                return !isWordEmpty
            }
            .map { [weak self] saveModel in
                let newModel = VocabularyRealm()
                newModel.id = self?.model == nil ? UUID().uuidString : self?.model?.id
                newModel.episodeID = self?.episodeID
                newModel.word = saveModel.word
                newModel.note = saveModel.note
                newModel.updateDate = Date()
                _ = realmService.add(object: newModel)
                return ()
            }
            .bind(to: event.saveSuccessfully)
            .disposed(by: bag)
    }
}
