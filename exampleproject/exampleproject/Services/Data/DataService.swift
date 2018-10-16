//
//  DataService.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/8/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import RealmSwift
import RxSwift
import RxRealm

protocol Serializable {
    associatedtype Element
    init?(jsonString: String)
    init?(type: Object)
}

enum Result<T> {
    case success(T)
    case failure(Swift.Error)
}


protocol DataService {
    func writeAll<T: Serializable>(from jsonArray: [[String: Any]], with targetType: T.Type) throws
    
    func readFirst<T: Serializable>(_ targetType: T.Type, callBack:  @escaping (Result<T?>) -> Void)
    func readAll<T: Serializable>(_ targetType: T.Type, callBack:  @escaping (Result<[T?]>) -> Void)
    
    func observeFirst<T: Serializable>(_ targetType: T.Type) -> Observable<T?>
    func observeAll<T: Serializable>(_ targetType: T.Type) -> Observable<[T?]>
}

public enum DataError: Error {
    case invalidData
    case wrongCasting(String)
    case parsingError
    case databaseError
    case none
}
