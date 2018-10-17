//
//  GoogleNewsService.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/7/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import Moya

enum GoogleNewsEndpoint {
    case Sources
    case TopHeadlines
}

extension GoogleNewsEndpoint: TargetType {
    var baseURL: URL {
        return URL(string: GoogleNewsEnv.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .Sources:
            return "/v2/sources"
        case .TopHeadlines:
            return "/v2/top-headlines"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .Sources:
            return .get
        case .TopHeadlines:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .Sources:
            return .requestPlain
        case .TopHeadlines:
            return .requestParameters(parameters: ["country" : "us"], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["X-Api-Key": GoogleNewsEnv.apiKey]
    }
    
}
