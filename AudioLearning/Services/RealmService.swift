//
//  RealmService.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/20.
//  Copyright © 2019 cshan. All rights reserved.
//

import RealmSwift
import RxSwift

final class RealmService<T: Object> {

    // Inputs
    private(set) var loadAll = PublishSubject<[String: Bool]?>()
    private(set) var filter = PublishSubject<(NSPredicate, [String: Bool]?)>()

    // Outputs
    private(set) var allObjects: Observable<[T]>!
    private(set) var filterObjects: Observable<[T]>!

    private var allObjectsSubject = PublishSubject<[T]>()
    private var filterObjectsSubject = PublishSubject<[T]>()

    private let bag = DisposeBag()

    init() {
        self.allObjects = allObjectsSubject.asObservable()
        self.filterObjects = filterObjectsSubject.asObservable()

        loadAll
            .subscribe(onNext: { [weak self] sortedByAsc in
                guard let self = self else { return }
                self.allObjectsSubject.onNext(self.loadAll(sortedByAsc: sortedByAsc))
            })
            .disposed(by: bag)

        filter
            .subscribe(onNext: { predicate, sortedByAsc in
                self.filterObjectsSubject.onNext(self.filter(by: predicate, sortedByAscending: sortedByAsc))
            })
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
        var result = true
        guard let realm = instanceRealm() else { return .just(false) }
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
        var result = true
        guard let realm = instanceRealm() else { return .just(false) }
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
        var result = true
        guard let realm = instanceRealm() else { return .just(false) }
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

    /// sortedByAsc = [key(String): Ascending(Bool)]
    private func loadAll(sortedByAsc: [String: Bool]? = nil) -> [T] {
        guard let realm = instanceRealm() else { return [] }
        let results = realm.objects(T.self)
        return sorted(from: results, by: sortedByAsc)
    }

    private func filter(by predicate: NSPredicate, sortedByAscending: [String: Bool]? = nil) -> [T] {
        guard let realm = instanceRealm() else { return [] }
        let results = realm.objects(T.self).filter(predicate)
        return sorted(from: results, by: sortedByAscending)
    }

    private func sorted(from results: Results<T>, by rules: [String: Bool]?) -> [T] {
        var results = results
        guard let rules = rules else { return Array(results) }
        for rule in rules {
            results = results.sorted(byKeyPath: rule.key, ascending: rule.value)
        }
        return Array(results)
    }
}
