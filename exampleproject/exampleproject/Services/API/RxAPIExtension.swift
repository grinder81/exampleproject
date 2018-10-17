//
//  RxAPIExtension.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/16/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import Moya
import RxSwift
import RxSwiftExt
import ObjectMapper

// Map JSON from API response
extension Observable where Element: EventConvertible, Element.ElementType: Response {
    func mapJSON() -> Observable<Event<JSON>> {
        return self.map { eventType in
            switch eventType.event {
            case let .next(response):
                if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? JSON {
                    return Event.next(json)
                }
                return Event.error(DataError.parsingError)
            case let .error(error):
                return Event.error(error)
            case .completed:
                return Event.completed
            }
        }
    }
}

extension Observable where Element: EventConvertible, Element.ElementType: Sequence {
    func writeModels<T>(using dataService: DataService, for type: T.Type) -> Observable<Event<Bool>> where T: Serializable {
        return self.map { eventType in
            switch eventType.event {
            case let .next(array):
                if let jsonArray =  array as? [JSON] {
                    do {
                        try dataService.writeAll(from: jsonArray, with: type)
                        return Event.next(true)
                    } catch {
                        return Event.error(error)
                    }
                }
                return Event.error(DataError.wrongCasting(#file))
            case let .error(error):
                return Event.error(error)
            case .completed:
                return Event.completed
            }
        }
    }
}

extension Observable where Element: Sequence {
    func writeModels<T>(using dataService: DataService, for type: T.Type) -> Observable<Bool> where T: Serializable {
        return self.do(onNext: { (array) in
            if let jsonArray =  array as? [JSON] {
                do {
                    try dataService.writeAll(from: jsonArray, with: type)
                } catch {
                    throw error
                }
            }
        }).map{ _ in true }
    }
}

