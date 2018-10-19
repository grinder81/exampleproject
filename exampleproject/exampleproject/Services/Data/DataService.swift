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
    init?(data: Data)
    init?(type: Object)
}

enum Result<T> {
    case success(T)
    case failure(Swift.Error)
}


protocol DataService {
    func convert<T: Serializable>(from jsonArray: [JSON], to targetType: T.Type) throws -> Result<[T]>
    
    /**
     Convert array of JSON object [<String, Any>] to Type T. T has the real DB type information underneth it.
     
     - parameter jsonArray: array of JSON object to be converted
     - parameter targetType: Serializable type, containg real type information
     - throws: Any kind of data conversion error will be thrown
     */
    func writeAll<T: Serializable>(from jsonArray: [JSON], with targetType: T.Type) throws
    
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
