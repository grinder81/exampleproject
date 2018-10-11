//
//  RealmDataService.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/8/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import Realm
import RxSwift
import RxRealm
import RealmSwift
import Moya
import ObjectMapper
import Moya_ObjectMapper

extension Results {
    func asObservable() -> Observable<[Element]> {
        return Observable.collection(from: self)
            .map{ Array($0) }
    }
}

final class RealmDataService: DataService {
    static let shared = RealmDataService()
    
    private init() {
        do {
            let config = Realm.Configuration(
                deleteRealmIfMigrationNeeded: true
            )
            Realm.Configuration.defaultConfiguration = config
            let realm = try Realm()
            print("Realm Database: \(realm.configuration.fileURL!)")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func observeOne<T: Serializable>(_ targetType: T.Type) -> Observable<T?> {
        return Observable<T?>.create { (observer) -> Disposable in
                if let realm = try? Realm(), let rlmType = targetType.Element.self as? Object.Type {
                    var object: Object?
                    try! realm.write {
                        object = realm.objects(rlmType).first
                    }
                    if let rlmObject = object {
                        observer.onNext(targetType.init(type: rlmObject))
                        observer.onCompleted()
                    } else {
                        observer.onError(DataError.WrongCasting(#file))
                    }
                } else {
                    observer.onError(DataError.InvalidData)
                }
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .utility))
            .observeOn(MainScheduler.asyncInstance)
    }
    
    func observeAll<T: Serializable>(_ targetType: T.Type) -> Observable<[T?]> {
        return Observable<[T?]>.create { (observer) -> Disposable in
                if let realm = try? Realm(), let rlmType = targetType.Element.self as? Object.Type {
                    var objects: Results<Object>?
                    try! realm.write {
                        objects = realm.objects(rlmType)
                    }
                    if let rlmObjects = objects {
                        observer.onNext(rlmObjects.map{ targetType.init(type: $0)} )
                        observer.onCompleted()
                    } else {
                        observer.onError(DataError.WrongCasting(#file))
                    }
                } else {
                    observer.onError(DataError.InvalidData)
                }
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .utility))
            .observeOn(MainScheduler.asyncInstance)
    }
}

extension Observable where E: Sequence, E.Iterator.Element: Object {
    func writeModels() -> Observable<Element> {
        return self.do(onNext: { (models) in
            let realm = try! Realm()
            try! realm.write {
                realm.add(models, update: true)
            }
        })
    }
}
