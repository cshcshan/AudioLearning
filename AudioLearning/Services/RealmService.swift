//
//  RealmService.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/20.
//  Copyright © 2019 cshan. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift

struct RealmSortField {
    let fieldName: String
    let isAscending: Bool
}

struct RealmFilter {
    let predicate: NSPredicate
    let sortFields: [RealmSortField]
}

final class RealmService<T: Object> {

    struct State {
        // Use `Driver` will cause `realm accessed from incorrect thread` issue, because managed instances of Object
        // are thread-confined, meaning that they can only be used on the thread on which they were created.
        let allItems: Observable<[T]>
        let filterItems: Observable<[T]>
    }

    struct Event {
        let loadAll = PublishRelay<[RealmSortField]>()
        let filter = PublishRelay<RealmFilter>()
    }

    // MARK: - Properties

    lazy var state = State(allItems: allItems.skip(1), filterItems: filterItems.skip(1))
    let event = Event()

    private let allItems = BehaviorRelay<[T]>(value: [])
    private let filterItems = BehaviorRelay<[T]>(value: [])
    private let bag = DisposeBag()

    init() {
        event.loadAll
            .map { [weak self] in self?.loadAll(by: $0) ?? [] }
            .bind(to: allItems)
            .disposed(by: bag)

        event.filter
            .map { [weak self] filter in
                self?.filter(by: filter.predicate, sortFields: filter.sortFields) ?? []
            }
            .bind(to: filterItems)
            .disposed(by: bag)
    }

    private func instanceRealm() -> Realm? {
        var realm: Realm?
        do {
            realm = try Realm()
        } catch {
            print("Got an error when instance Realm.\n \(error)")
        }
        return realm
    }

    func add(objects: [T]) -> Observable<[T]?> {
        guard let realm = instanceRealm() else { return .just(nil) }

        realm.beginWrite()
        realm.add(objects, update: .modified)
        do {
            try realm.commitWrite()
        } catch {
            print("Got an error when save objects to Realm.\n \(error)")
            return .just(nil)
        }

        return .just(objects)
    }

    func add(object: T) -> Observable<T?> {
        guard let realm = instanceRealm() else { return .just(nil) }

        realm.beginWrite()
        realm.add(object, update: .modified)
        do {
            try realm.commitWrite()
        } catch {
            print("Got an error when save an object to Realm.\n \(error)")
            return .just(nil)
        }

        return .just(object)
    }

    func update(predicate: NSPredicate, updateHandler: (_ data: Results<T>?) -> Void) -> Observable<Bool> {
        guard let realm = instanceRealm() else { return .just(false) }

        var result = true
        let objects = realm.objects(T.self).filter(predicate)

        realm.beginWrite()
        updateHandler(objects)
        realm.add(objects, update: .modified)
        do {
            try realm.commitWrite()
        } catch {
            result = false
            print("Got an error when update objects from Realm.\n \(error)")
        }

        return .just(result)
    }

    func delete(predicate: NSPredicate) -> Observable<Bool> {
        guard let realm = instanceRealm() else { return .just(false) }

        var result = true
        let objects = realm.objects(T.self).filter(predicate)

        realm.beginWrite()
        realm.delete(objects)
        do {
            try realm.commitWrite()
        } catch {
            result = false
            print("Got an error when delete objects from Realm.\n \(error)")
        }

        return .just(result)
    }

    func deleteAll() -> Observable<Bool> {
        guard let realm = instanceRealm() else { return .just(false) }

        var result = true
        let objects = realm.objects(T.self)

        realm.beginWrite()
        realm.delete(objects)
        do {
            try realm.commitWrite()
        } catch {
            result = false
            print("Got an error when delete objects from Realm.\n \(error)")
        }

        return .just(result)
    }

    private func loadAll(by sortFields: [RealmSortField] = []) -> [T] {
        guard let realm = instanceRealm() else { return [] }
        let results = realm.objects(T.self)
        return sorted(from: results, by: sortFields)
    }

    private func filter(by predicate: NSPredicate, sortFields: [RealmSortField] = []) -> [T] {
        guard let realm = instanceRealm() else { return [] }
        let results = realm.objects(T.self).filter(predicate)
        return sorted(from: results, by: sortFields)
    }

    private func sorted(from results: Results<T>, by sortFields: [RealmSortField]) -> [T] {
        let sortingResult = sortFields.reduce(results) { partialResult, sortField in
            partialResult.sorted(byKeyPath: sortField.fieldName, ascending: sortField.isAscending)
        }
        return Array(sortingResult)
    }
}
