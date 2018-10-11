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

protocol DataService {
    func observeOne<T: Serializable>(_ targetType: T.Type) -> Observable<T?>
    func observeAll<T: Serializable>(_ type: T.Type) -> Observable<[T?]>
}

public enum DataError: Swift.Error {
    case InvalidData
    case WrongCasting(String)
}
