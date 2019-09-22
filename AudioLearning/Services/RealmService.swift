//
//  RealmService.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/20.
//  Copyright © 2019 cshan. All rights reserved.
//

import RealmSwift

class RealmService {
    
    static let shared = RealmService()
    
    private init() {}
    
    func instanceRealm() -> Realm? {
        var realm: Realm?
        do {
            realm = try Realm()
        } catch let error {
            print("Got an error when instance Realm.\n \(error)")
        }
        return realm
    }
    
    func add<T: Object>(objects: [T]) -> [T]? {
        guard let realm = instanceRealm() else { return nil }
        realm.beginWrite()
        realm.add(objects, update: .modified)
        do {
            try realm.commitWrite()
        } catch let error {
            print("Got an error when save objects to Realm.\n \(error)")
            return nil
        }
        return objects
    }
    
    func add<T: Object>(object: T) -> T? {
        guard let realm = instanceRealm() else { return nil }
        realm.beginWrite()
        realm.add(object, update: .modified)
        do {
            try realm.commitWrite()
        } catch let error {
            print("Got an error when save an object to Realm.\n \(error)")
            return nil
        }
        return object
    }
    
    func update<T: Object>(type: T.Type, predicate: NSPredicate, updateHandler: ((_ data: Results<T>?) -> Void)) -> Bool {
        var result = true
        guard let realm = instanceRealm() else { return false }
        let objects = realm.objects(type).filter(predicate)
        realm.beginWrite()
        updateHandler(objects)
        realm.add(objects, update: .modified)
        do {
            try realm.commitWrite()
        } catch let error {
            result = false
            print("Got an error when update objects from Realm.\n \(error)")
        }
        return result
    }
    
    func delete<T: Object>(type: T.Type, predicate: NSPredicate) -> Bool {
        var result = true
        guard let realm = instanceRealm() else { return false }
        let objects = realm.objects(type).filter(predicate)
        realm.beginWrite()
        realm.delete(objects)
        do {
            try realm.commitWrite()
        } catch let error {
            result = false
            print("Got an error when delete objects from Realm.\n \(error)")
        }
        return result
    }
    
    func deleteAll<T: Object>(type: T.Type) -> Bool {
        var result = true
        guard let realm = instanceRealm() else { return false }
        let objects = realm.objects(T.self)
        realm.beginWrite()
        realm.delete(objects)
        do {
            try realm.commitWrite()
        } catch let error {
            result = false
            print("Got an error when delete objects from Realm.\n \(error)")
        }
        return result
    }
    
    /// sortedByAsc = [key(String): Ascending(Bool)]
    func loadAll<T: Object>(sortedByAsc: [String: Bool]? = nil) -> [T] {
        guard let realm = instanceRealm() else { return [] }
        let results = realm.objects(T.self)
        return sorted(from: results, by: sortedByAsc)
    }
    
    func filter<T: Object>(by predicate: NSPredicate, sortedByAscending: [String: Bool]? = nil) -> [T] {
        guard let realm = instanceRealm() else { return [] }
        let results = realm.objects(T.self).filter(predicate)
        return sorted(from: results, by: sortedByAscending)
    }
    
    private func sorted<T: Object>(from results: Results<T>, by rules: [String: Bool]?) -> [T] {
        var results = results
        guard let rules = rules else { return Array(results) }
        for rule in rules {
            results = results.sorted(byKeyPath: rule.key, ascending: rule.value)
        }
        return Array(results)
    }
}
