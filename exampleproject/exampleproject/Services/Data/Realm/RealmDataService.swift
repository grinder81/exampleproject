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
                callBack(.failure(DataError.invalidData))
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
                callBack(.failure(DataError.invalidData))
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
        return Observable.error(DataError.wrongCasting(#file))
    }
    
    func observeAll<T: Serializable>(_ targetType: T.Type) -> Observable<[T?]> {
        if let realm = try? Realm(), let rlmType = targetType.Element.self as? Object.Type {
            return realm.objects(rlmType).asObservable()
                .map{ $0.map{ targetType.init(type: $0) } }
                .observeOn(MainScheduler.asyncInstance)
        }
        return Observable.error(DataError.wrongCasting(#file))
    }
    
    func writeAll<T>(from jsonArray: [JSON], with targetType: T.Type) throws where T : Serializable {
        if let realm = try? Realm(), let mappable = targetType.Element.self as? Mappable.Type {
            let rlmModels = jsonArray.map { (dictionary) -> Object? in
                let map = Map(mappingType: .fromJSON, JSON: dictionary)
                let object = mappable.init(map: map)
                return object as? Object
                }.compactMap { $0 }
            do {
                try realm.write {
                    realm.add(rlmModels, update: true)
                }
            } catch {
                throw error
            }
        } else {
            throw DataError.wrongCasting(#file)
        }
    }
    
    
    func convert<T>(from jsonArray: [JSON], to targetType: T.Type) throws -> Result<[T]> where T : Serializable {
        do {
            let models = try jsonArray.map { (dictionary) -> T in
                if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
                    let model = targetType.init(data: jsonData) {
                    return model
                } else {
                    throw DataError.parsingError
                }
            }
            return .success(models)
        } catch {
            return .failure(DataError.parsingError)
        }
    }
    
    private func writeModel<T: Object>(_ model: T, synchronous: Bool = false) {
        let update = {
            let realm = try! Realm()
            try! realm.write({
                realm.add(model, update: true)
            })
        }
        if synchronous {
            update()
        } else {
            DispatchQueue.global(qos: .utility).async {
                update()
            }
        }
    }
}

//extension Observable where E: Sequence, E.Iterator.Element: Object {
//    func writeModels() -> Observable<Element> {
//        return self.do(onNext: { (models) in
//            let realm = try! Realm()
//            try! realm.write {
//                realm.add(models, update: true)
//            }
//        })
//    }
//}

//extension Observable where Element == Response {
//    func writeModels<T>(_ type: T.Type, atKeyPath: String? = nil) -> Observable<T> where T: BaseMappable {
//        return self.map{ try? JSONSerialization.jsonObject(with: $0.data, options: []) }
//            .map({ (json) -> T? in
//                guard let json = json as? [String: Any] else { return nil }
//                if let keyPath = atKeyPath, let keyPathJSON = json[keyPath] as? [String: Any] {
//                    return type.init(JSON: keyPathJSON)
//                }
//                return type.init(JSON: json)
//            })
//            .do(onNext: { (model) in
//                
//            }).unwrap()
//    }
//}


//extension Observable where Element == Response {
//    func writeModels<T>(using dataService: DataService, for type: T.Type, atKeyPath: String? = nil) -> Observable<Bool> where T: Serializable {
//        return self.map({ (response) -> Bool in
//            if let data = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any], let source =  data["sources"] as? [[String: Any]], let mappable = type.Element.self as? Mappable.Type {
//                let array = source.map { (dictionary) -> Mappable? in
//                    let map = Map(mappingType: .fromJSON, JSON: dictionary)
//                    let object = mappable.init(map: map)
//                    return object
//                }
//            }
//            return true
//        })
//    }
//}
