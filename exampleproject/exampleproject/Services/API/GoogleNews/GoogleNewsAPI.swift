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
    func getSources<T: Serializable>(_ targetType: T.Type) -> Observable<Bool>
    func getHealines<T: Serializable>(_ targetType: T.Type) -> Observable<Bool>
}

final class GoogleNewsAPI {
    private let dataServiceProvider: DataService
    private let apiServiceProvider: MoyaProvider<GoogleNewsEndpoint>
    
    init(apiService: MoyaProvider<GoogleNewsEndpoint> = MoyaProvider<GoogleNewsEndpoint>(plugins: [NetworkLoggerPlugin(verbose: true)]), dataService: DataService = RealmDataService.shared) {
        self.apiServiceProvider     = apiService
        self.dataServiceProvider    = dataService
    }
}

extension GoogleNewsAPI: GoogleNewsAPIService {
    func getHealines<T>(_ targetType: T.Type) -> Observable<Bool> where T : Serializable {
        return self.apiServiceProvider.rx
            .request(GoogleNewsEndpoint.TopHeadlines)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .debug()
            .asObservable()
            .materialize()
            .mapJSON()
            .mapHeadlines()
            .writeModels(using: self.dataServiceProvider, for: targetType)
            .dematerialize()
            .observeOn(MainScheduler.asyncInstance)
    }
    
    func getSources<T: Serializable>(_ targetType: T.Type) -> Observable<Bool> {
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
    
    func mapHeadlines() -> Observable<Event<[JSON]>> {
        return self.map { eventType in
            switch eventType.event {
            case let .next(json):
                if let dictionary = json as? JSON, let jsonArray = dictionary["articles"] as? [JSON] {
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
