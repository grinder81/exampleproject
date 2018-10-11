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

struct GoogleNewsSettings {
    let baseUrl: String
    let apiKey: String
}

let GoogleNewsEnv = GoogleNewsSettings(
    baseUrl: "https://newsapi.org",
    apiKey: "1944816ba04b445c9264dbb74f4e5b32")

protocol GoogleNewsAPIService {
    func getSources() -> Observable<Bool>
}

final class GoogleNewsAPI {
    private let serviceProvider: MoyaProvider<GoogleNewsEndpoint>
    
    init(provider: MoyaProvider<GoogleNewsEndpoint> = MoyaProvider<GoogleNewsEndpoint>()) {
        self.serviceProvider = provider
    }
}

extension GoogleNewsAPI: GoogleNewsAPIService {
    // TODO: Make it database independent 
    func getSources() -> Observable<Bool> {
        return self.serviceProvider.rx
            .request(GoogleNewsEndpoint.Sources)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .asObservable()
            .map{ try? $0.mapArray(SourceRealm.self, atKeyPath: "sources") }
            .unwrap()
            .writeModels()
            .map{ _ in true }
            .catchErrorJustReturn(false)
            .observeOn(MainScheduler.asyncInstance)
    }
}
