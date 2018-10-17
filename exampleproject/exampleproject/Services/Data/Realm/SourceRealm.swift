//
//  RLMSource.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/8/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//
import Foundation
import RealmSwift
import ObjectMapper
import Moya_ObjectMapper

class SourceRealm: Object {
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var desc: String!
    @objc dynamic var url: String!
    @objc dynamic var category: String!
    @objc dynamic var language: String!
    @objc dynamic var country: String!
    
    required convenience init?(map: Map) {
        self.init()
        self.mapping(map: map)
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    private enum Field: String {
        case id             = "id"
        case name           = "name"
        case description    = "description"
        case url            = "url"
        case category       = "category"
        case language       = "language"
        case country        = "country"
    }
}

extension SourceRealm: Mappable {
    func mapping(map: Map) {
        self.id         <- map[Field.id.rawValue]
        self.name       <- map[Field.name.rawValue]
        self.desc       <- map[Field.description.rawValue]
        self.url        <- map[Field.url.rawValue]
        self.category   <- map[Field.category.rawValue]
        self.language   <- map[Field.language.rawValue]
        self.country    <- map[Field.country.rawValue]
    }
}
