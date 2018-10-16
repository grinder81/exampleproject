//
//  GoogleNewsAPI.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/7/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import Moya
import RxSwift
import RxSwiftExt
import ObjectMapper

typealias JSON = [String: Any]

struct GoogleNewsSettings {
    let baseUrl: String
    let apiKey: String
}

let GoogleNewsEnv = GoogleNewsSettings(
    baseUrl: "https://newsapi.org",
    apiKey: "1944816ba04b445c9264dbb74f4e5b32")

protocol GoogleNewsAPIService {
    func getSources<T: Serializable>(_ targetType: T.Type, atKeyPath: String?) -> Observable<Bool>
}

final class GoogleNewsAPI {
    private let dataServiceProvider: DataService
    private let apiServiceProvider: MoyaProvider<GoogleNewsEndpoint>
    
    init(apiService: MoyaProvider<GoogleNewsEndpoint> = MoyaProvider<GoogleNewsEndpoint>(), dataService: DataService = RealmDataService.shared) {
        self.apiServiceProvider     = apiService
        self.dataServiceProvider    = dataService
    }
}

extension GoogleNewsAPI: GoogleNewsAPIService {
    func getSources<T: Serializable>(_ targetType: T.Type, atKeyPath: String? =  nil) -> Observable<Bool> {
        return self.apiServiceProvider.rx
            .request(GoogleNewsEndpoint.Sources)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .asObservable()
            .materialize()
            .mapJSON()
            .mapSources()
            .writeModels(using: self.dataServiceProvider, for: targetType)
            .dematerialize()
            .observeOn(MainScheduler.asyncInstance)
    }
}

// Mapping for source API JSON
extension Observable where Element: EventConvertible {
    func mapSources() -> Observable<Event<[JSON]>> {
        return self.map { eventType in
            switch eventType.event {
            case let .next(json):
                if let dictionary = json as? JSON, let jsonArray = dictionary["sources"] as? [JSON] {
                    return Event.next(jsonArray)
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
    func writeModels<T>(using dataService: DataService, for type: T.Type, atKeyPath: String? = nil) -> Observable<Event<Bool>> where T: Serializable {
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
    func writeModels<T>(using dataService: DataService, for type: T.Type, atKeyPath: String? = nil) -> Observable<Bool> where T: Serializable {
        return self.do(onNext: { (array) in
            if let jsonArray =  array as? [[String: Any]] {
                do {
                    try dataService.writeAll(from: jsonArray, with: type)
                } catch {
                    throw error
                }
            }
        }).map{ _ in true }
    }
}

