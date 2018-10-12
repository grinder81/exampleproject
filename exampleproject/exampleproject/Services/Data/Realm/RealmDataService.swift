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
    
    func readFirst<T>(_ targetType: T.Type, callBack: @escaping (Result<T?>) -> Void) where T : Serializable {
        DispatchQueue.global(qos: .utility).async {
            var object: T?
            if let realm = try? Realm(),
                let rlmType = targetType.Element.self as? Object.Type,
                let targetObject = realm.objects(rlmType).first {
                object = targetType.init(type: targetObject)
                DispatchQueue.main.async {
                    callBack(.success(object))
                }
                return
            }
            DispatchQueue.main.async {
                callBack(.failure(DataError.InvalidData))
            }
        }
    }
    
    func readAll<T>(_ targetType: T.Type, callBack: @escaping (Result<[T?]>) -> Void) where T : Serializable {
        DispatchQueue.global(qos: .utility).async {
            var objects: [T?] = []
            if let realm = try? Realm(),
                let rlmType = targetType.Element.self as? Object.Type {
                objects = realm.objects(rlmType).map{ targetType.init(type: $0) }
                DispatchQueue.main.async {
                    callBack(.success(objects))
                }
                return
            }
            DispatchQueue.main.async {
                callBack(.failure(DataError.InvalidData))
            }
        }
    }
    
    // TODO: WARNING you can't use GCD to register notification on Realm
    // Only way to do using RunLoop which mean Own thread.
    func observeFirst<T: Serializable>(_ targetType: T.Type) -> Observable<T?> {
        if let realm = try? Realm(), let rlmType = targetType.Element.self as? Object.Type {
            return realm.objects(rlmType).asObservable()
                .map{ $0.first }
                .unwrap()
                .map{ targetType.init(type: $0) }
                .observeOn(MainScheduler.asyncInstance)
        }
        return Observable.error(DataError.WrongCasting(#file))
    }
    
    func observeAll<T: Serializable>(_ targetType: T.Type) -> Observable<[T?]> {
        if let realm = try? Realm(), let rlmType = targetType.Element.self as? Object.Type {
            return realm.objects(rlmType).asObservable()
                .map{ $0.map{ targetType.init(type: $0) } }
                .observeOn(MainScheduler.asyncInstance)
        }
        return Observable.error(DataError.WrongCasting(#file))
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
