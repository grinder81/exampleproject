//
//  Source.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/8/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import Foundation
import RealmSwift

struct Source: Codable {
    let id: String
    let name: String
    let description: String
    let url: String
    let category: String
    let language: String
    let country: String
}

//TODO: Make it database independent
extension Source: Serializable {
    init?(type: Object) {
        guard let source = type as? SourceRealm else {
            return nil
        }
        self.id             = source.id
        self.name           = source.name
        self.description    = source.desc
        self.url            = source.url
        self.category       = source.category
        self.language       = source.language
        self.country        = source.country
    }
    
    init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8), let source = try? JSONDecoder().decode(Source.self, from: data) else {
            return nil
        }
        self.id             = source.id
        self.name           = source.name
        self.description    = source.description
        self.url            = source.url
        self.category       = source.category
        self.language       = source.language
        self.country        = source.country
    }
    
    typealias Element = SourceRealm
}
